// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mojo.internal.isolate.manager;

class Notifications {
  static const int kAddWatch = Manager.kAddWatch;
  static const int kRemoveWatch = Manager.kRemoveWatch;
  static const int kCloseWatch = Manager.kCloseWatch;

  /// A map from watched endpoint, to a pair of port and signals.
  ///
  /// All endpoints in this map must be owned by the local manager.
  ///
  /// We don't support multiple watches on the same endpoint.
  Map<Endpoint, List> _watches = <Endpoint, List>{};

  int addWatch(Endpoint endpoint, SendPort port, int signals) {
    if (endpoint.isClosed) return MojoResult.kFailedPrecondition;
    _watches[endpoint] = [port, signals];
    return MojoResult.kOk;
  }

  int removeWatch(Endpoint endpoint) {
    _watches.remove(endpoint);
    return MojoResult.kOk;
  }

  Map<Endpoint, List<Completer>> _bindNotifications =
      <Endpoint, List<Completer>>{};

  /// Returns a Future that is completed, when the endpoint is bound.
  ///
  /// The endpoint must be pending.
  Future onBound(Endpoint endpoint) {
    assert(endpoint.isPending);
    var completer = new Completer();
    _bindNotifications.putIfAbsent(endpoint, () => []).add(completer);
    return completer.future;
  }

  // Notifies that the given [endpoint] has been successfully bound.
  void notifyBound(Endpoint endpoint) {
    List<Completer> completers = _bindNotifications.remove(endpoint);
    if (completers != null) {
      completers.forEach((completer) => completer.complete());
    }
  }

  _handleControlMessage(msg) {
    int command = msg[0];
    switch (command) {
      case kAddWatch:
        Endpoint endpoint = Endpoint.decode(msg[1]);
        SendPort port = msg[2];
        int signals = msg[3];
        return addWatch(endpoint, port, signals);
      case kRemoveWatch:
        Endpoint endpoint = Endpoint.decode(msg[1]);
        return removeWatch(endpoint);
    }
  }
}
