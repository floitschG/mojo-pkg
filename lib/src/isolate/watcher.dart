// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of mojo.internal.isolate.manager;

///
class Watcher {

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

  void notifyEndpointStatusChange(Endpoint endpoint) {
    List watch = _watches[endpoint];
    if (watch == null) return;

    SendPort notificationPort = watch[0];
    int signals = watch[1];
    int status = endpoint.status;
    if (_satisfiesSignal(status, signals)) {
      notificationPort.send(status);
    }
  }

  bool _satisfiesSignal(int status, int signals) => (status & signals) != 0;
}
