// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mojo.internal.isolate.manager;

/// An endpoint of a pipe.
///
/// As long as the endpoint hasn't been bound, the manager identified by the
/// [creatorPort] is responsible for it.
///
/// Once it has been bound, the [creatorPort] is only used to uniquely identify
/// endpoints across multiple isolates.
class Endpoint {
  /// The port of the Manager that created this endpoint.
  ///
  /// May be different from the manager port that is responsible for handling
  /// the endpoint (and thus the pipe).
  final SendPort creatorPort;

  final int id;

  Endpoint(this.creatorPort, this.id);

  static Endpoint decode(List encoded) {
    return new Endpoint(encoded[0], encoded[1]);
  }

  bool operator ==(other) {
    return other is Endpoint &&
        other.id == id &&
        other.creatorPort == creatorPort;
  }

  int get hashCode {
    return (creatorPort.hashCode * 8 + id) & 0x7FFFFFFF;
  }

  Endpoint get peer => new Endpoint(creatorPort, EndpointManager._peerId(id));

  void bind() {
    manager.endpoints._bind(this);
  }

  List encode() => [creatorPort, id];

  void sendToCreator(msg) {
    creatorPort.send(msg);
  }

  void sendToPeerManager(msg) {
    manager.endpoints._sendToPeerManager(this, msg);
  }

  /// Whether this endpoint was bound, or is in the process of binding.
  ///
  /// The endpoint might still be pending (see [isPending]).
  bool get isBound => manager.endpoints._isBound(this);

  bool get isClosed => manager.endpoints._isClosed(this);
  bool get isPeerClosed => manager.endpoints._isClosed(peer);

  /// Whether this endpoint is writable.
  ///
  /// In the isolate implementation, endpoints are always writable, unless they
  /// have been closed.
  // TODO(floitsch): consider making them only writable, once the other side
  // has connected.
  bool get isWritable => !isClosed;

  bool get isReadable => manager.endpoints._isReadable(this);

  /// Returns the current status according to [MojoHandleSignals].
  int get status {
    // TODO(floitsch): don't use magic constants.
    int result = 0;
    if (isReadable) result += MojoHandleSignals.kReadable;
    if (isWritable) result += MojoHandleSignals.kWritable;
    if (isPeerClosed) result += MojoHandleSignals.kPeerClosed;
    return result;
  }
}

class EndpointManager {
  static const int kBind = Manager.kBind;
  static const int kConnect = Manager.kConnect;
  static const int kClosed = Manager.kClosed;
  static const int kMessage = Manager.kMessage;

  static int _idCounter = 0;

  static SendPort get managerPort => manager.port;

  /// Returns the id of the peer endpoint of the pipe.
  static int _peerId(int id) => id.isEven ? id + 1 : id - 1;

  // Creator manager methods.
  // ========================

  List<Endpoint> createPipe() {
    int id1 = _idCounter++;
    int id2 = _idCounter++;
    assert(id2 == _peerId(id1));
    assert(id1 == _peerId(id2));

    var endPoint1 = new Endpoint(managerPort, id1);
    var endPoint2 = new Endpoint(managerPort, id2);
    return [endPoint1, endPoint2];
  }

  /// Mapping from half-bound local endpoints to the manager port that owns the
  /// bound endpoint (and is thus responsible for message passing).
  ///
  /// As soon as a full connection is established, the endpoint is removed from
  /// this map, so that memory isn't unnecessarily retained.
  // Note: all the endpoints in this map have been created on this isolate and
  // therefore have a `creatorPort` equal to the local manager's port.
  // In theory we could thus maintain a mapping from int to SendPort.
  Map<Endpoint, SendPort> _halfBoundEndpoints = <Endpoint, SendPort>{};

  /// Connects the given [endpoint] to the other end of the pipe.
  ///
  /// As soon as both ends of the pipe have been bound, sends the respective
  /// peer-manager ports to both endpoints so they can start communicating.
  void _registerBind(Endpoint endpoint, SendPort endPointManager) {
    assert(endpoint.creatorPort == managerPort);
    assert(!_halfBoundEndpoints.containsKey(endpoint));

    Endpoint peer = endpoint.peer;
    SendPort peerManager = _halfBoundEndpoints[peer];
    if (peerManager != null) {
      // The other end was already bound.
      // Establish a connection.
      _halfBoundEndpoints.remove(peer);
      peerManager.send([kConnect, endpoint.encode(), endPointManager]);
      endPointManager.send([kConnect, peer.encode(), peerManager]);
    } else {
      // The peer wasn't bound yet.
      _halfBoundEndpoints[endpoint] = endPointManager;
    }
  }

  // Owning manager methods
  // ======================

  /// The endpoints this manager owns.
  ///
  /// Endpoints can be owned by managers that are different than the creator
  /// manager.
  ///
  /// The manager has to handle message-passing for endpoints it owns.
  Set<Endpoint> _ownedEndpoints = new Set<Endpoint>();

  /// Mapping from locally bound endpoints to the manager that owns
  /// the peer endpoint.
  Map<Endpoint, SendPort> _peerEndpointManagers = <Endpoint, SendPort>{};

  /// A buffer for messages that have been sent to the peers.
  ///
  /// These messages are sent as soon as a connection has been established.
  ///
  /// The keys are the source endpoints.
  Map<Endpoint, dynamic> _pendingMessages = <Endpoint, dynamic>{};

  /// Returns true if the given [endpoint] has been bound locally.
  ///
  /// This predicate does not look at other isolates. That is, it will return
  /// `false` if the given [endpoint] has been bound on a different isolate.
  bool _isBound(Endpoint endpoint) => _ownedEndpoints.contains(endpoint);

  /// Binds the given endpoint and returns the owning manager-port.
  void _bind(Endpoint endpoint) {
    // Make us the owner of the given endpoint.
    bool alreadyBound = !_ownedEndpoints.add(endpoint);

    // If we already owned it, just return.
    if (alreadyBound) return;

    endpoint.sendToCreator([kBind, endpoint.encode(), managerPort]);
  }

  /// Establishes a connection between the given [peerEndpoint] and the locally
  /// bound corresponding endpoint.
  void _connect(Endpoint peerEndpoint, SendPort peerManager) {
    Endpoint localEndpoint = peerEndpoint.peer;
    assert(_ownedEndpoints.contains(localEndpoint));

    _peerEndpointManagers[peerEndpoint] = peerManager;

    List pendingMessages = _pendingMessages.remove(localEndpoint);
    pendingMessages ??= [];
    pendingMessages.forEach(localEndpoint.sendToPeerManager);

    manager._notifyEndpointStatusChange(localEndpoint);
  }

  /// Endpoints (or their peers) that this isolate owned, but have been closed.
  // TODO(floitsch): we should try to find a different way to keep track of
  // them, since this approach would leak memory.
  Set<Endpoint> _closedEndpoints = new Set<Endpoint>();

  // TODO(floitsch): we could also use a different signal.
  bool _isClosed(Endpoint endpoint) => _closedEndpoints.contains(endpoint);

  Map<Endpoint, Queue> _receivedData = <Endpoint, Queue>{};

  bool _isReadable(Endpoint endpoint) {
    Queue data = _receivedData[endpoint];
    return data != null && data.isNotEmpty;
  }

  void _sendToPeerManager(Endpoint endpoint, msg) {
    assert(endpoint.isBound);
    SendPort peerManager = _peerEndpointManagers[endpoint];
    if (peerManager == null) {
      // The connection hasn't been established yet.
      // Queue the message.
      _pendingMessages.putIfAbsent(endpoint, () => []).add(msg);
    } else {
      peerManager.send(msg);
    }
  }

  int close(Endpoint endpoint) {
    if (endpoint.isClosed) return MojoResult.kInvalidArgument;
    _closedEndpoints.add(endpoint);
    endpoint.sendToPeerManager([kClosed, endpoint.encode()]);
    return MojoResult.kOk;
  }

  void _closePeerEndpoint(Endpoint endpoint) {
    _closedEndpoints.add(endpoint);
    manager._notifyEndpointStatusChange(endpoint.peer);
  }

  int writeMessage(Endpoint endpoint, ByteData data, int numBytes,
      List<List> handleTokens, int flags) {
    if (endpoint.isClosed) return MojoResult.kInvalidArgument;
    if (data == null && numBytes != 0) return MojoResult.kInvalidArgument;
    if (data != null && numBytes <= 0) return MojoResult.kInvalidArgument;

    if (data != null && data.lengthInBytes != numBytes) {
      data = new ByteData.view(data.buffer, 0, numBytes);
    }
    endpoint
        .sendToPeerManager([kMessage, endpoint.encode(), data, handleTokens]);
    return MojoResult.kOk;
  }

  void _receivePeerMessage(
      Endpoint peer, ByteData data, List<List> handleTokens) {
    Endpoint endpoint = peer.peer;
    assert(endpoint.isBound);
    assert(!peer.isClosed);

    Queue bufferedMessages =
        _receivedData.putIfAbsent(endpoint, () => new Queue());
    bool wasEmpty = bufferedMessages.isEmpty;
    bufferedMessages.add([data, handleTokens]);
    if (wasEmpty) {
      manager._notifyEndpointStatusChange(endpoint);
    }
  }

  List readMessage(Endpoint endpoint, ByteData data, int numBytes,
      List<List> handleTokens, int flags) {
    if (data == null && numBytes != 0) return null;
    if (data != null && numBytes <= 0) return null;

    Queue bufferedMessages = _receivedData[endpoint];
    if (bufferedMessages == null || bufferedMessages.isEmpty) {
      return [MojoResult.kShouldWait, 0, 0];
    }

    int handleTokensLength = handleTokens == null ? 0 : handleTokens.length;

    List message = bufferedMessages.first;
    ByteData receivedData = message[0];
    List receivedHandleTokens = message[1];
    int bytesAvailable = receivedData == null ? 0 : receivedData.lengthInBytes;
    int handlesAvailable =
        receivedHandleTokens == null ? 0 : receivedHandleTokens.length;

    int resultInteger;
    if (numBytes < bytesAvailable || handleTokensLength < handlesAvailable) {
      resultInteger = MojoResult.kResourceExhausted;
      if (flags & MojoMessagePipeEndpoint.READ_FLAG_MAY_DISCARD != 0) {
        bufferedMessages.removeFirst();
      }
    } else {
      if (bytesAvailable != 0) {
        Uint8List source = new Uint8List.view(receivedData.buffer);
        Uint8List target = new Uint8List.view(data.buffer);
        target.setRange(0, bytesAvailable, source);
      }
      if (handlesAvailable != 0) {
        handleTokens.setRange(0, handlesAvailable, receivedHandleTokens);
      }
      bufferedMessages.removeFirst();
      resultInteger = MojoResult.kOk;
    }
    return [resultInteger, bytesAvailable, handlesAvailable];
  }

  void queryAndReadMessage(Endpoint endpoint, int flags, List result) {
    int resultIndex = 0;
    int dataIndex = 1;
    int handlesIndex = 2;
    int bytesAvailableIndex = 3;
    int handlesAvailableIndex = 4;

    ByteData data = result[dataIndex];
    int numBytes = data == null ? 0 : data.lengthInBytes;

    List<List> handleTokens = result[handlesIndex];
    int handleTokensLength = handleTokens == null ? 0 : handleTokens.length;

    Queue bufferedMessages = _receivedData[endpoint];

    // If there is no message, the caller has to wait.
    if (bufferedMessages == null || bufferedMessages.isEmpty) {
      result[resultIndex] = MojoResult.kShouldWait;
      result[bytesAvailableIndex] = 0;
      result[handlesAvailableIndex] = 0;
      return;
    }

    List message = bufferedMessages.first;
    ByteData receivedData = message[0];
    List receivedHandleTokens = message[1];
    int bytesAvailable = receivedData == null ? 0 : receivedData.lengthInBytes;
    int handlesAvailable =
        receivedHandleTokens == null ? 0 : receivedHandleTokens.length;

    int resultInteger;
    // If the given byte-data is not big enough, replace it with the received
    // one. Otherwise copy.
    if (numBytes < bytesAvailable) {
      result[dataIndex] = receivedData;
    } else if (bytesAvailable != 0) {
      Uint8List source = new Uint8List.view(receivedData.buffer);
      Uint8List target = new Uint8List.view(data.buffer);
      target.setRange(0, bytesAvailable, source);
    }

    // If the given tokens list is not big enough, replace it with the received
    // one. Otherwise copy.
    if (handleTokensLength < handlesAvailable) {
      result[handlesIndex] = receivedHandleTokens;
    } else if (handlesAvailable != 0) {
      handleTokens.setRange(0, handlesAvailable, receivedHandleTokens);
    }

    // Consume the message.
    bufferedMessages.removeFirst();

    // Signal a successful operation.
    resultInteger = MojoResult.kOk;

    result[resultIndex] = resultInteger;
    result[bytesAvailableIndex] = bytesAvailable;
    result[handlesAvailableIndex] = handlesAvailable;
  }

  List wait(Endpoint endpoint, int signals, int deadline) {
    if (deadline != 0) {
      throw new UnsupportedError(
          "Can't wait with deadline != 0 (deadline == $deadline)");
    }
    int resultCode;
    int satisfiedSignals = MojoHandleSignals.kNone;
    int satisfiableSignals = MojoHandleSignals.kNone;

    if (!endpoint.isBound) {
      resultCode = MojoResult.kInvalidArgument;
    } else {
      // Satisfiable signals are the ones that could potentially become true in
      // the future.
      satisfiableSignals = MojoHandleSignals.kPeerClosed;
      if (!endpoint.isClosed) {
        satisfiableSignals += MojoHandleSignals.kWritable;
      }
      if (!endpoint.isPeerClosed) {
        satisfiableSignals += MojoHandleSignals.kReadable;
      }

      int status = endpoint.status;
      satisfiedSignals = status & signals;

      if (signals == MojoHandleSignals.kNone) {
        resultCode = MojoResult.kFailedPrecondition;
      } else {
        if (satisfiedSignals != 0) {
          resultCode = MojoResult.kOk;
        } else {
          resultCode = MojoResult.kDeadlineExceeded;
        }
      }
    }
    return [
      resultCode,
      [satisfiedSignals, satisfiableSignals]
    ];
  }

  // Message handling.
  // =================

  void _handleMessage(List message) {
    int command = message[0];
    switch (command) {
      case kBind:
        Endpoint endpoint = Endpoint.decode(message[1]);
        SendPort owningManager = message[2];
        _registerBind(endpoint, owningManager);
        break;
      case kConnect:
        Endpoint endpoint = Endpoint.decode(message[1]);
        SendPort peerManager = message[2];
        _connect(endpoint, peerManager);
        break;
      case kClosed:
        Endpoint peer = Endpoint.decode(message[1]);
        _closePeerEndpoint(peer);
        break;
      case kMessage:
        Endpoint peer = Endpoint.decode(message[1]);
        ByteData data = message[2];
        List<List> handleTokens = message[3];
        _receivePeerMessage(peer, data, handleTokens);
        break;
    }
  }
}
