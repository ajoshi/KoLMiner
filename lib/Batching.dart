import 'dart:async';
import 'dart:ui';

import 'SafeTextEditingController.dart';

class StatusRequestBatcher extends AutoDisposable {
  late Stream<bool> eventStream;
  bool hasPendingRequest = false;
  late StreamSubscription<bool> batchedRequestSubscription;
  VoidCallback onEvent;

  StatusRequestBatcher(this.onEvent) {
    eventStream = Stream.periodic(Duration(seconds: 2), (int count) {
      bool temp = hasPendingRequest;
      hasPendingRequest = false;
      return temp;
    });
    batchedRequestSubscription = eventStream.listen((event) {
      if(event){
        onEvent();
      } else {
      }
    });
  }

  void addRequest() {
    // whatever
    hasPendingRequest = true;
  }

  bool getValue(int i) {
    return hasPendingRequest;
  }

  Stream<bool>? getEventStream() {
    return eventStream;
  }

  @override
  void dispose() {
    batchedRequestSubscription.cancel();
  }
}