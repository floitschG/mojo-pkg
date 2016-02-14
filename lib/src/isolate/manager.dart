// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library mojo.internal.isolate.manager;

import 'dart:async';
import 'dart:collection' show Queue;
import 'dart:isolate';
import 'dart:typed_data';

import '../../core.dart'
    show
        MojoResult,
        MojoHandleSignals,
        MojoHandleSignalsState,
        MojoMessagePipeEndpoint,
        MojoWaitResult,
        MojoWaitManyResult;

part 'endpoints.dart';
part 'watcher.dart';

class Manager {
  final SendPort port;

  final EndpointManager endpoints = new EndpointManager();
  final Watcher watcher = new Watcher();

  factory Manager() {
    RawReceivePort rawPort = new RawReceivePort();
    var result = new Manager._(rawPort.sendPort);
    rawPort.handler = result._handleMessage;
    return result;
  }

  Manager._(this.port);

  static const int kBind = 0;
  static const int kConnect = 1;
  static const int kClosed = 2;
  static const int kMessage = 3;

  _handleMessage(List message) {
    int command = message[0];
    switch (command) {
      case kBind:
      case kConnect:
      case kClosed:
      case kMessage:
        endpoints._handleMessage(message);
        break;
    }
  }

  List createPipe() {
    List pipe = endpoints.createPipe();
    Endpoint end1 = pipe[0];
    Endpoint end2 = pipe[1];
    return [MojoResult.kOk, end1.encode(), end2.encode()];
  }

  int addWatch(List handleToken, SendPort port, int signals) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    endpoint.bind();
    var result = watcher.addWatch(endpoint, port, signals);
    return result ?? MojoResult.kOk;
  }

  int removeWatch(List handleToken) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    assert(endpoint.isBound);
    var result = watcher.removeWatch(endpoint);
    return result ?? MojoResult.kOk;
  }

  Future<int> closeWatch(List handleToken, bool shouldWait) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    watcher.removeWatch(endpoint);
    // In the isolate implementation we don't need to wait.
    var resultCode = close(handleToken);
    return new Future.value(resultCode ?? MojoResult.kOk);
  }

  void _notifyEndpointStatusChange(Endpoint endpoint) {
    watcher.notifyEndpointStatusChange(endpoint);
  }

  int close(List handleToken) {
    return endpoints.close(Endpoint.decode(handleToken));
  }

  List wait(List handleToken, int signals, int deadline) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    endpoint.bind();
    return endpoints.wait(endpoint, signals, deadline);
  }

  List waitMany(List<List> handleTokens, List<int> signals, int deadline) {
    // Returns a list of:
    // - MojoResult integer
    // - the index the triggered the return
    // - list of states.
    throw new UnimplementedError("waitMany");
  }

  int writeMessage(List handleToken, ByteData data, int numBytes,
      List<Object> handleTokens, int flags) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    endpoint.bind();
    return endpoints.writeMessage(endpoint, data, numBytes, handleTokens, flags);
  }

  List readMessage(List handleToken, ByteData data, int numBytes, List<Object> handleTokens, int flags) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    endpoint.bind();
    return endpoints.readMessage(endpoint, data, numBytes, handleTokens, flags);
  }

  void queryAndReadMessage(List handleToken, int flags, List result) {
    Endpoint endpoint = Endpoint.decode(handleToken);
    endpoint.bind();
    endpoints.queryAndReadMessage(endpoint, flags, result);
  }
}

final Manager manager = new Manager();
