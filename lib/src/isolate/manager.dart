// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library mojo.internal.isolate.manager;

import 'dart:async';
import 'dart:isolate';

import '../../core.dart'
    show
        MojoResult,
        MojoHandleSignals,
        MojoHandleSignalsState,
        MojoWaitResult,
        MojoWaitManyResult;

part 'endpoints.dart';
part 'notifications.dart';

class Manager {
  final SendPort port;

  final EndpointManager endpoints = new EndpointManager();
  final Notifications notifications = new Notifications();

  factory Manager() {
    RawReceivePort rawPort = new RawReceivePort();
    var result = new Manager._(rawPort.sendPort);
    rawPort.handler = result._handleControlMessage;
    return result;
  }

  Manager._(this.port);

  static const int kRemoteBind = 0;
  static const int kFullyBound = 1;
  static const int kOwn = 2;
  static const int kAddWatch = 3;
  static const int kRemoveWatch = 4;
  static const int kCloseWatch = 5;

  _handleControlMessage(List message) {
    int command = message[0];
    switch (command) {
      case kRemoteBind:
      case kFullyBound:
      case kOwn:
        endpoints._handleRemoteMessage(message);
        break;
      case kAddWatch:
      case kRemoveWatch:
      case kCloseWatch:
        return notifications._handleControlMessage(message);
    }
  }

  List createPipe() => endpoints.createPipe();

  int addWatch(Endpoint endpoint, SendPort port, int signals) {
    endpoint.bind();
    var result =
        endpoint.sendToOwner([kAddWatch, endpoint.encode(), port, signals]);
    return result ?? MojoResult.kOk;
  }

  int removeWatch(Endpoint endpoint) {
    assert(endpoint.isBound);
    var result = endpoint.sendToOwner([kRemoveWatch, endpoint.encode()]);
    return result ?? MojoResult.kOk;
  }

  Future<int> closeWatch(Endpoint endpoint, bool shouldWait) {
    assert(endpoint.isBound);
    notifications.removeWatch(endpoint);
    if (shouldWait) {
      return _closeNotify(endpoint);
    } else {
      var resultCode = close(endpoint);
      return new Future.value(resultCode ?? MojoResult.kOk);
    }
  }

  int close(Endpoint endpoint) {
    // TODO(floitsch): implement.
  }

  Future<int> _closeNotify(Endpoint endpoint) {
    // TODO(floitsch): implement.
  }
}

final Manager manager = new Manager();
