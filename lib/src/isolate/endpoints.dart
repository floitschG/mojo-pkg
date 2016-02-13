// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mojo.internal.isolate.manager;

abstract class Endpoint {
  int get id;

  /// The port of the manager that owns this endpoint.
  ///
  /// Should only be used for shortcutting, since it may be `null`, even though
  /// the port is already bound.
  SendPort get _owningPort;

  static Endpoint decode(List encoded) {
    SendPort managerPort = encoded[0];
    int id = encoded[1];
    if (managerPort == manager.port) {
      return new LocalEndpoint(id);
    } else {
      return new RemoteEndpoint(managerPort, id);
    }
  }

  void bind();

  /// Sends a the given [msg] to the owning manager of this endpoint.
  ///
  /// If the endpoint is local, then returns the result of the calling the
  /// manager. Otherwise returns `null`.
  sendToOwner(msg) {
    return manager.endpoints._sendToOwner(this, msg);
  }

  // TODO(floitsch): implement.
  bool get isClosed => false;

  /// Whether this endpoint was bound, or is in the process of binding.
  ///
  /// The endpoint might still be pending (see [isPending]).
  bool get isBound => manager.endpoints._isBound(this);

  /// Whether this endpoint is pending.
  ///
  /// An endpoint is pending, if the binding has been initiated, but not yet
  /// completed.
  bool get isPending => manager.endpoints._pendingEndpoints.contains(this);

  List encode();
}

class LocalEndpoint extends Endpoint {
  final int id;
  SendPort _owningPort;

  LocalEndpoint(this.id);

  bool operator ==(other) {
    return other is LocalEndpoint && other.id == id;
  }

  int get hashCode => id;

  LocalEndpoint get other {
    return new LocalEndpoint(EndpointManager._otherId(id));
  }

  void bind() {
    if (_owningPort != null) return;
    _owningPort = manager.endpoints._bindLocalEndpoint(this);
  }

  List encode() {
    return [manager.port, id];
  }
}

class RemoteEndpoint extends Endpoint {
  /// The port of the Manager that created this endpoint.
  ///
  /// May be different from the manager port that is responsible for handling
  /// the endpoint (and thus the pipe).
  final SendPort managerPort;

  final int id;

  // Just to avoid calls to the manager.
  //
  // When non-null, it means that the port is bound. When `null` it could
  // be bound, but we just don't know yet.
  SendPort _owningPort;

  RemoteEndpoint(this.managerPort, this.id);

  bool operator ==(other) {
    return other is RemoteEndpoint &&
        other.id == id &&
        other.managerPort == managerPort;
  }

  int get hashCode {
    return (managerPort.hashCode * 8 + id) & 0x7FFFFFFF;
  }

  RemoteEndpoint get other =>
      new RemoteEndpoint(managerPort, EndpointManager._otherId(id));

  void bind() {
    if (_owningPort != null) return;
    // Since _bindRemoteEndpoint is an asynchronous operation, we can get
    // `null` as response.
    _owningPort = manager.endpoints._bindRemoteEndpoint(this);
  }

  List encode() {
    return [manager.port, id];
  }
}

class EndpointManager {
  static const int kOwn = Manager.kOwn;
  static const int kFullyBound = Manager.kFullyBound;
  static const int kRemoteBind = Manager.kRemoteBind;

  static int _idCounter = 0;

  static SendPort get managerPort => manager.port;

  /// Returns the id of the other endpoint of the pipe.
  static int _otherId(int id) => id.isEven ? id + 1 : id - 1;

  List<Endpoint> createPipe() {
    int id1 = _idCounter++;
    int id2 = _idCounter++;
    assert(id2 == _otherId(id1));
    assert(id1 == _otherId(id2));

    var endPoint1 = new LocalEndpoint(id1);
    var endPoint2 = new LocalEndpoint(id2);
    return [MojoResult.kOk, endPoint1, endPoint2];
  }

  /// Mapping from a locally bound endpoint to the remote manager that owns
  /// the endpoint.
  Map<Endpoint, SendPort> _remotelyOwnedEndpoints = <Endpoint, SendPort>{};

  /// The endpoints this manager owns.
  ///
  /// The manager has to handle message-passing for endpoints it owns.
  // TODO(floitsch): we don't need to add both sides of a pipe. It's enough to
  // add one of the two.
  Set<Endpoint> _ownedEndpoints = new Set<Endpoint>();

  /// Mapping from half-bound local endpoints to the manager port that owns the
  /// bound endpoint (and is thus responsible for message passing).
  ///
  /// As soon as a full connection is established, the endpoint is removed from
  /// this map, so that memory isn't unnecessarily retained.
  Map<LocalEndpoint, SendPort> _halfBoundEndpoints =
      <LocalEndpoint, SendPort>{};

  /// Returns true if there was an attempt to bind the given [endpoint].
  ///
  /// For remote endpoints, the binding might still be in process.
  bool _isBound(Endpoint endpoint) {
    return _ownedEndpoints.contains(endpoint) ||
        _remotelyOwnedEndpoints.containsKey(endpoint) ||
        _pendingEndpoints.contains(endpoint);
  }

  /// Binds the given endpoint and returns the owning manager-port.
  SendPort _bindLocalEndpoint(LocalEndpoint endpoint) {
    if (_ownedEndpoints.contains(endpoint)) {
      // The endpoint is owned by this manager.
      return managerPort;
    }

    var remotePort = _remotelyOwnedEndpoints[endpoint];
    if (remotePort != null) {
      // The pipe has been bound remotely and another manager is responsible
      // for the communication.
      return remotePort;
    }

    assert(!_halfBoundEndpoints.containsKey(endpoint));

    SendPort otherPort = _halfBoundEndpoints[endpoint.other];
    if (otherPort != null) {
      // The other end of the pipe has been bound.
      if (otherPort == managerPort) {
        // The local manager owns both endpoints.
        _ownedEndpoints.add(endpoint);
      } else {
        // Another manager is responsible for this pipe.
        _remotelyOwnedEndpoints[endpoint] = otherPort;
      }
      // The connection has been established. Remove the other endpoint from the
      // half-bound endpoints.
      _halfBoundEndpoints.remove(endpoint.other);
      return otherPort;
    }

    // At this point, there should be no endpoint of the pipe that is bound.
    // Establish a half-bound connection, by binding the endpoint to this
    // manager.
    assert(!_ownedEndpoints.contains(endpoint.other));

    _ownedEndpoints.add(endpoint);
    _halfBoundEndpoints[endpoint] = managerPort;
    return managerPort;
  }

  /// Set of endpoints that are in the process of being bound.
  Set<RemoteEndpoint> _pendingEndpoints = new Set<RemoteEndpoint>();

  /// Binds the given remote endpoint.
  ///
  /// This is an asynchronous operation, since we have to communicate with
  /// the isolate that created the endpoint.
  SendPort _bindRemoteEndpoint(RemoteEndpoint endpoint) {
    if (_ownedEndpoints.contains(endpoint)) {
      // The endpoint is owned by this manager.
      return managerPort;
    }

    var remotePort = _remotelyOwnedEndpoints[endpoint];
    if (remotePort != null) {
      // The pipe has been bound remotely and another manager is responsible
      // for the communication.
      return remotePort;
    }

    if (_pendingEndpoints.contains(endpoint)) {
      // Already in the process of binding this endpoint.
      return null;
    }

    endpoint.managerPort.send([kRemoteBind, endpoint.encode(), managerPort]);
    _pendingEndpoints.add(endpoint);
    return null;
  }

  /// Handle a bind-request from a remote manager.
  void _remoteBind(LocalEndpoint endpoint, SendPort remoteManager) {
    // The endpoint must not be bound yet.
    assert(!_ownedEndpoints.contains(endpoint));
    assert(!_halfBoundEndpoints.containsKey(endpoint));

    var other = endpoint.other;
    SendPort otherManager = _halfBoundEndpoints[other];
    if (otherManager != null) {
      // Other side has already been bound, and we thus have an owning
      // manager.
      remoteManager.send([kFullyBound, endpoint.encode(), otherManager]);
      // Now that the connection is established, remove the endpoint from the
      // half endpoints.
      _halfBoundEndpoints.remove(other);
      return;
    }
    // The port isn't owned yet. Make the requesting manager the owner.
    remoteManager.send([kOwn, endpoint.encode()]);
    _halfBoundEndpoints[endpoint] = remoteManager;
  }

  void _handleRemoteMessage(List message) {
    int command = message[0];
    switch (command) {
      case kRemoteBind:
        LocalEndpoint endpoint = Endpoint.decode(message[1]);
        SendPort remoteManager = message[2];
        _remoteBind(endpoint, remoteManager);
        break;
      case kFullyBound:
        RemoteEndpoint endpoint = Endpoint.decode(message[1]);
        SendPort otherManager = message[2];
        _remotelyOwnedEndpoints[endpoint] = otherManager;
        _pendingEndpoints.remove(endpoint);
        manager.notifications.notifyBound(endpoint);
        break;
      case kOwn:
        RemoteEndpoint endpoint = Endpoint.decode(message[1]);
        _ownedEndpoints.add(endpoint);
        _pendingEndpoints.remove(endpoint);
        manager.notifications.notifyBound(endpoint);
        break;
    }
  }

  /// Returns true if we know that the port is locally owned.
  ///
  /// This function may only be called once an endpoint has been bound.
  bool _isLocallyOwned(Endpoint endpoint) {
    if (endpoint._owningPort != null) {
      return endpoint._owningPort == manager.port;
    }
    return _ownedEndpoints.contains(this);
  }

  _sendToOwner(Endpoint endpoint, msg) {
    assert(endpoint.isBound);

    if (_isLocallyOwned(endpoint)) {
      return manager._handleControlMessage(msg);
    } else if (endpoint._owningPort != null) {
      endpoint._owningPort.send(msg);
      return null;
    } else {
      assert(_pendingEndpoints.contains(endpoint));
      manager.notifications.onBound(endpoint).then((_) {
        _sendToOwner(endpoint, msg);
      });
    }
  }

}
