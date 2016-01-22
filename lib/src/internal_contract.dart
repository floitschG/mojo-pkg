// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate' show SendPort;
import 'dart:typed_data' show ByteData;

// The MojoHandleWatcher sends a stream of events to application isolates that
// register Mojo handles with it. Application isolates make the following calls:
//
// add(handle, port, signals) - Instructs the MojoHandleWatcher isolate to add
//     'handle' to the set of handles it watches, and to notify the calling
//     isolate only for the events specified by 'signals' using the send port
//     'port'
//
// remove(handle) - Instructs the MojoHandleWatcher isolate to remove 'handle'
//     from the set of handles it watches. This allows the application isolate
//     to, e.g., pause the stream of events.
//
// close(handle) - Notifies the HandleWatcherIsolate that a handle it is
//     watching should be removed from its set and closed.
class MojoHandleWatcher {
  // If wait is true, returns a future that resolves only after the handle
  // has actually been closed by the handle watcher. Otherwise, returns a
  // future that resolves immediately.
  static Future<int> close(int mojoHandle, {bool wait: false}) {
    throw new UnsupportedError("MojoHandleWatcher.close on contract");
  }

  static int add(int mojoHandle, SendPort port, int signals) {
    throw new UnsupportedError("MojoHandleWatcher.add on contract");
  }

  static int remove(int mojoHandle) {
    throw new UnsupportedError("MojoHandleWatcher.remove on contract");
  }

  static int timer(Object ignored, SendPort port, int deadline) {
    throw new UnsupportedError("MojoHandleWatcher.timer on contract");
  }
}

class MojoCoreNatives {
  static int getTimeTicksNow() {
    throw new UnsupportedError("MojoCoreNatives.getTimeTicksNow on contract");
  }

  static int timerMillisecondClock() {
    throw new UnsupportedError(
        "MojoCoreNatives.timerMillisecondClock on contract");
  }
}

class MojoHandleNatives {
  static void addOpenHandle(int handle, {String description}) {
    throw new UnsupportedError("MojoHandleNatives.addOpenHandle on contract");
  }

  static void removeOpenHandle(int handle) {
    throw new UnsupportedError(
        "MojoHandleNatives.removeOpenHandle on contract");
  }

  static bool reportOpenHandles() {
    throw new UnsupportedError(
        "MojoHandleNatives.reportOpenHandles on contract");
  }

  static bool setDescription(int handle, String description) {
    throw new UnsupportedError("MojoHandleNatives.setDescription on contract");
  }

  static int registerFinalizer(Object eventStream, int handle) {
    throw new UnsupportedError(
        "MojoHandleNatives.registerFinalizer on contract");
  }

  static int close(int handle) {
    throw new UnsupportedError("MojoHandleNatives.close on contract");
  }

  static List wait(int handle, int signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.woit on contract");
  }

  static List waitMany(List<int> handles, List<int> signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.wainMany on contract");
  }
}

class MojoHandleWatcherNatives {
  static int sendControlData(int controlHandle, int commandCode,
      int handleOrDeadline, SendPort port, int data) {
    throw new UnsupportedError(
        "MojoHandleWatcherNatives.sendControlData on contract");
  }
}

class MojoMessagePipeNatives {
  static List MojoCreateMessagePipe(int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoCreateMessagePipe on contract");
  }

  static int MojoWriteMessage(
      int handle, ByteData data, int numBytes, List<int> handles, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoWriteMessage on contract");
  }

  static List MojoReadMessage(
      int handle, ByteData data, int numBytes, List<int> handles, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoReadMessage on contract");
  }

  static List MojoQueryAndReadMessage(int handle, int flags, List result) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoQueryAndReadMessage on contract");
  }
}

class MojoDataPipeNatives {
  static List MojoCreateDataPipe(
      int elementBytes, int capacityBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoCreateDataPipe on contract");
  }

  static List MojoWriteData(
      int handle, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoWriteData on contract");
  }

  static List MojoBeginWriteData(int handle, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginWriteData on contract");
  }

  static int MojoEndWriteData(int handle, int bytesWritten) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoEndWriteData on contract");
  }

  static List MojoReadData(int handle, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoReadData on contract");
  }

  static List MojoBeginReadData(int handle, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginReadData on contract");
  }

  static int MojoEndReadData(int handle, int bytesRead) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoEndReadData on contract");
  }
}

class MojoSharedBufferNatives {
  static List Create(int numBytes, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Create on contract");
  }

  static List Duplicate(int bufferHandle, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Duplicate on contract");
  }

  static List Map(int bufferHandle, int offset, int numBytes, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Map on contract");
  }
}
