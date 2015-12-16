// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library service_describer_mojom;

import 'dart:async';

import 'package:mojo/bindings.dart' as bindings;
import 'package:mojo/core.dart' as core;
import 'package:mojo/mojo/bindings/types/mojom_types.mojom.dart' as mojom_types_mojom;
const String serviceDescriberInterfaceName = "_ServiceDescriber";



class ServiceDescriberDescribeServiceParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  String interfaceName = null;
  Object descriptionRequest = null;

  ServiceDescriberDescribeServiceParams() : super(kVersions.last.size);

  static ServiceDescriberDescribeServiceParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriberDescribeServiceParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriberDescribeServiceParams result = new ServiceDescriberDescribeServiceParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.interfaceName = decoder0.decodeString(8, false);
    }
    if (mainDataHeader.version >= 0) {
      
      result.descriptionRequest = decoder0.decodeInterfaceRequest(16, false, ServiceDescriptionStub.newFromEndpoint);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(interfaceName, 8, false);
    
    encoder0.encodeInterfaceRequest(descriptionRequest, 16, false);
  }

  String toString() {
    return "ServiceDescriberDescribeServiceParams("
           "interfaceName: $interfaceName" ", "
           "descriptionRequest: $descriptionRequest" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class ServiceDescriptionGetTopLevelInterfaceParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  ServiceDescriptionGetTopLevelInterfaceParams() : super(kVersions.last.size);

  static ServiceDescriptionGetTopLevelInterfaceParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetTopLevelInterfaceParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetTopLevelInterfaceParams result = new ServiceDescriptionGetTopLevelInterfaceParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "ServiceDescriptionGetTopLevelInterfaceParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class ServiceDescriptionGetTopLevelInterfaceResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  mojom_types_mojom.MojomInterface mojomInterface = null;

  ServiceDescriptionGetTopLevelInterfaceResponseParams() : super(kVersions.last.size);

  static ServiceDescriptionGetTopLevelInterfaceResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetTopLevelInterfaceResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetTopLevelInterfaceResponseParams result = new ServiceDescriptionGetTopLevelInterfaceResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(8, false);
      result.mojomInterface = mojom_types_mojom.MojomInterface.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(mojomInterface, 8, false);
  }

  String toString() {
    return "ServiceDescriptionGetTopLevelInterfaceResponseParams("
           "mojomInterface: $mojomInterface" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["mojomInterface"] = mojomInterface;
    return map;
  }
}


class ServiceDescriptionGetTypeDefinitionParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String typeKey = null;

  ServiceDescriptionGetTypeDefinitionParams() : super(kVersions.last.size);

  static ServiceDescriptionGetTypeDefinitionParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetTypeDefinitionParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetTypeDefinitionParams result = new ServiceDescriptionGetTypeDefinitionParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.typeKey = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(typeKey, 8, false);
  }

  String toString() {
    return "ServiceDescriptionGetTypeDefinitionParams("
           "typeKey: $typeKey" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["typeKey"] = typeKey;
    return map;
  }
}


class ServiceDescriptionGetTypeDefinitionResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  mojom_types_mojom.UserDefinedType type = null;

  ServiceDescriptionGetTypeDefinitionResponseParams() : super(kVersions.last.size);

  static ServiceDescriptionGetTypeDefinitionResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetTypeDefinitionResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetTypeDefinitionResponseParams result = new ServiceDescriptionGetTypeDefinitionResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
        result.type = mojom_types_mojom.UserDefinedType.decode(decoder0, 8);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUnion(type, 8, true);
  }

  String toString() {
    return "ServiceDescriptionGetTypeDefinitionResponseParams("
           "type: $type" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["type"] = type;
    return map;
  }
}


class ServiceDescriptionGetAllTypeDefinitionsParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  ServiceDescriptionGetAllTypeDefinitionsParams() : super(kVersions.last.size);

  static ServiceDescriptionGetAllTypeDefinitionsParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetAllTypeDefinitionsParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetAllTypeDefinitionsParams result = new ServiceDescriptionGetAllTypeDefinitionsParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "ServiceDescriptionGetAllTypeDefinitionsParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class ServiceDescriptionGetAllTypeDefinitionsResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Map<String, mojom_types_mojom.UserDefinedType> definitions = null;

  ServiceDescriptionGetAllTypeDefinitionsResponseParams() : super(kVersions.last.size);

  static ServiceDescriptionGetAllTypeDefinitionsResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ServiceDescriptionGetAllTypeDefinitionsResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ServiceDescriptionGetAllTypeDefinitionsResponseParams result = new ServiceDescriptionGetAllTypeDefinitionsResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(8, true);
      if (decoder1 == null) {
        result.definitions = null;
      } else {
        decoder1.decodeDataHeaderForMap();
        List<String> keys0;
        List<mojom_types_mojom.UserDefinedType> values0;
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
            keys0 = new List<String>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
              keys0[i2] = decoder2.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i2, false);
            }
          }
        }
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForUnionArray(keys0.length);
            values0 = new List<mojom_types_mojom.UserDefinedType>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
                values0[i2] = mojom_types_mojom.UserDefinedType.decode(decoder2, bindings.ArrayDataHeader.kHeaderSize + bindings.kUnionSize * i2);
                if (values0[i2] == null) {
                  throw new bindings.MojoCodecError(
                    'Trying to decode null union for non-nullable mojom_types_mojom.UserDefinedType.');
                }
            }
          }
        }
        result.definitions = new Map<String, mojom_types_mojom.UserDefinedType>.fromIterables(
            keys0, values0);
      }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    if (definitions == null) {
      encoder0.encodeNullPointer(8, true);
    } else {
      var encoder1 = encoder0.encoderForMap(8);
      int size0 = definitions.length;
      var keys0 = definitions.keys.toList();
      var values0 = definitions.values.toList();
      
      {
        var encoder2 = encoder1.encodePointerArray(keys0.length, bindings.ArrayDataHeader.kHeaderSize, bindings.kUnspecifiedArrayLength);
        for (int i1 = 0; i1 < keys0.length; ++i1) {
          
          encoder2.encodeString(keys0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
        }
      }
      
      {
        var encoder2 = encoder1.encodeUnionArray(values0.length, bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, bindings.kUnspecifiedArrayLength);
        for (int i1 = 0; i1 < values0.length; ++i1) {
          
          encoder2.encodeUnion(values0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kUnionSize * i1, false);
        }
      }
    }
  }

  String toString() {
    return "ServiceDescriptionGetAllTypeDefinitionsResponseParams("
           "definitions: $definitions" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["definitions"] = definitions;
    return map;
  }
}

const int kServiceDescriber_describeService_name = 0;
const String ServiceDescriberName = "mojo::bindings::types::ServiceDescriber";

abstract class ServiceDescriber {
  void describeService(String interfaceName, Object descriptionRequest);

}


class ServiceDescriberProxyImpl extends bindings.Proxy {
  ServiceDescriberProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  ServiceDescriberProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  ServiceDescriberProxyImpl.unbound() : super.unbound();

  static ServiceDescriberProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriberProxyImpl"));
    return new ServiceDescriberProxyImpl.fromEndpoint(endpoint);
  }

  String get name => ServiceDescriberName;

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "ServiceDescriberProxyImpl($superString)";
  }
}


class _ServiceDescriberProxyCalls implements ServiceDescriber {
  ServiceDescriberProxyImpl _proxyImpl;

  _ServiceDescriberProxyCalls(this._proxyImpl);
    void describeService(String interfaceName, Object descriptionRequest) {
      if (!_proxyImpl.isBound) {
        _proxyImpl.proxyError("The Proxy is closed.");
        return;
      }
      var params = new ServiceDescriberDescribeServiceParams();
      params.interfaceName = interfaceName;
      params.descriptionRequest = descriptionRequest;
      _proxyImpl.sendMessage(params, kServiceDescriber_describeService_name);
    }
  
}


class ServiceDescriberProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  ServiceDescriber ptr;
  final String name = ServiceDescriberName;

  ServiceDescriberProxy(ServiceDescriberProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _ServiceDescriberProxyCalls(proxyImpl);

  ServiceDescriberProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new ServiceDescriberProxyImpl.fromEndpoint(endpoint) {
    ptr = new _ServiceDescriberProxyCalls(impl);
  }

  ServiceDescriberProxy.fromHandle(core.MojoHandle handle) :
      impl = new ServiceDescriberProxyImpl.fromHandle(handle) {
    ptr = new _ServiceDescriberProxyCalls(impl);
  }

  ServiceDescriberProxy.unbound() :
      impl = new ServiceDescriberProxyImpl.unbound() {
    ptr = new _ServiceDescriberProxyCalls(impl);
  }

  factory ServiceDescriberProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    ServiceDescriberProxy p = new ServiceDescriberProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static ServiceDescriberProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriberProxy"));
    return new ServiceDescriberProxy.fromEndpoint(endpoint);
  }

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "ServiceDescriberProxy($impl)";
  }
}


class ServiceDescriberStub extends bindings.Stub {
  ServiceDescriber _impl = null;

  ServiceDescriberStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  ServiceDescriberStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  ServiceDescriberStub.unbound() : super.unbound();

  static ServiceDescriberStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriberStub"));
    return new ServiceDescriberStub.fromEndpoint(endpoint);
  }

  static const String name = ServiceDescriberName;



  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case kServiceDescriber_describeService_name:
        var params = ServiceDescriberDescribeServiceParams.deserialize(
            message.payload);
        _impl.describeService(params.interfaceName, params.descriptionRequest);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  ServiceDescriber get impl => _impl;
  set impl(ServiceDescriber d) {
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "ServiceDescriberStub($superString)";
  }

  int get version => 0;
}

const int kServiceDescription_getTopLevelInterface_name = 0;
const int kServiceDescription_getTypeDefinition_name = 1;
const int kServiceDescription_getAllTypeDefinitions_name = 2;
const String ServiceDescriptionName = null;

abstract class ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory = null]);
  dynamic getTypeDefinition(String typeKey,[Function responseFactory = null]);
  dynamic getAllTypeDefinitions([Function responseFactory = null]);

}


class ServiceDescriptionProxyImpl extends bindings.Proxy {
  ServiceDescriptionProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  ServiceDescriptionProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  ServiceDescriptionProxyImpl.unbound() : super.unbound();

  static ServiceDescriptionProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriptionProxyImpl"));
    return new ServiceDescriptionProxyImpl.fromEndpoint(endpoint);
  }

  String get name => ServiceDescriptionName;

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case kServiceDescription_getTopLevelInterface_name:
        var r = ServiceDescriptionGetTopLevelInterfaceResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case kServiceDescription_getTypeDefinition_name:
        var r = ServiceDescriptionGetTypeDefinitionResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case kServiceDescription_getAllTypeDefinitions_name:
        var r = ServiceDescriptionGetAllTypeDefinitionsResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "ServiceDescriptionProxyImpl($superString)";
  }
}


class _ServiceDescriptionProxyCalls implements ServiceDescription {
  ServiceDescriptionProxyImpl _proxyImpl;

  _ServiceDescriptionProxyCalls(this._proxyImpl);
    dynamic getTopLevelInterface([Function responseFactory = null]) {
      var params = new ServiceDescriptionGetTopLevelInterfaceParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          kServiceDescription_getTopLevelInterface_name,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getTypeDefinition(String typeKey,[Function responseFactory = null]) {
      var params = new ServiceDescriptionGetTypeDefinitionParams();
      params.typeKey = typeKey;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          kServiceDescription_getTypeDefinition_name,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getAllTypeDefinitions([Function responseFactory = null]) {
      var params = new ServiceDescriptionGetAllTypeDefinitionsParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          kServiceDescription_getAllTypeDefinitions_name,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
}


class ServiceDescriptionProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  ServiceDescription ptr;
  final String name = ServiceDescriptionName;

  ServiceDescriptionProxy(ServiceDescriptionProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _ServiceDescriptionProxyCalls(proxyImpl);

  ServiceDescriptionProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new ServiceDescriptionProxyImpl.fromEndpoint(endpoint) {
    ptr = new _ServiceDescriptionProxyCalls(impl);
  }

  ServiceDescriptionProxy.fromHandle(core.MojoHandle handle) :
      impl = new ServiceDescriptionProxyImpl.fromHandle(handle) {
    ptr = new _ServiceDescriptionProxyCalls(impl);
  }

  ServiceDescriptionProxy.unbound() :
      impl = new ServiceDescriptionProxyImpl.unbound() {
    ptr = new _ServiceDescriptionProxyCalls(impl);
  }

  factory ServiceDescriptionProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    ServiceDescriptionProxy p = new ServiceDescriptionProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static ServiceDescriptionProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriptionProxy"));
    return new ServiceDescriptionProxy.fromEndpoint(endpoint);
  }

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "ServiceDescriptionProxy($impl)";
  }
}


class ServiceDescriptionStub extends bindings.Stub {
  ServiceDescription _impl = null;

  ServiceDescriptionStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  ServiceDescriptionStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  ServiceDescriptionStub.unbound() : super.unbound();

  static ServiceDescriptionStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ServiceDescriptionStub"));
    return new ServiceDescriptionStub.fromEndpoint(endpoint);
  }

  static const String name = ServiceDescriptionName;


  ServiceDescriptionGetTopLevelInterfaceResponseParams _ServiceDescriptionGetTopLevelInterfaceResponseParamsFactory(mojom_types_mojom.MojomInterface mojomInterface) {
    var mojo_factory_result = new ServiceDescriptionGetTopLevelInterfaceResponseParams();
    mojo_factory_result.mojomInterface = mojomInterface;
    return mojo_factory_result;
  }
  ServiceDescriptionGetTypeDefinitionResponseParams _ServiceDescriptionGetTypeDefinitionResponseParamsFactory(mojom_types_mojom.UserDefinedType type) {
    var mojo_factory_result = new ServiceDescriptionGetTypeDefinitionResponseParams();
    mojo_factory_result.type = type;
    return mojo_factory_result;
  }
  ServiceDescriptionGetAllTypeDefinitionsResponseParams _ServiceDescriptionGetAllTypeDefinitionsResponseParamsFactory(Map<String, mojom_types_mojom.UserDefinedType> definitions) {
    var mojo_factory_result = new ServiceDescriptionGetAllTypeDefinitionsResponseParams();
    mojo_factory_result.definitions = definitions;
    return mojo_factory_result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case kServiceDescription_getTopLevelInterface_name:
        var params = ServiceDescriptionGetTopLevelInterfaceParams.deserialize(
            message.payload);
        var response = _impl.getTopLevelInterface(_ServiceDescriptionGetTopLevelInterfaceResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  kServiceDescription_getTopLevelInterface_name,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              kServiceDescription_getTopLevelInterface_name,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case kServiceDescription_getTypeDefinition_name:
        var params = ServiceDescriptionGetTypeDefinitionParams.deserialize(
            message.payload);
        var response = _impl.getTypeDefinition(params.typeKey,_ServiceDescriptionGetTypeDefinitionResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  kServiceDescription_getTypeDefinition_name,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              kServiceDescription_getTypeDefinition_name,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case kServiceDescription_getAllTypeDefinitions_name:
        var params = ServiceDescriptionGetAllTypeDefinitionsParams.deserialize(
            message.payload);
        var response = _impl.getAllTypeDefinitions(_ServiceDescriptionGetAllTypeDefinitionsResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  kServiceDescription_getAllTypeDefinitions_name,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              kServiceDescription_getAllTypeDefinitions_name,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  ServiceDescription get impl => _impl;
  set impl(ServiceDescription d) {
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "ServiceDescriptionStub($superString)";
  }

  int get version => 0;
}


