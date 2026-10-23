import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/utils/date_extention.dart';
import '../models/category_dm.dart';
import '../models/event_dm.dart';

abstract interface class EventRepository {
  Future<void> createEvent(EventDm event);
  Future<void> updateEvent(EventDm event);
  Future<void> deleteEvent(String eventId);
  Stream<EventDm?> watchEvent(String eventId);
}

class EventsDatabase implements EventRepository {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<EventDm> getCollectionReference() {
    return firestore
        .collection("events")
        .withConverter(
          fromFirestore: EventDm.fromFirestore,
          toFirestore: (event, options) => event.toFirestore(),
        );
  }

  @override
  Future<void> createEvent(EventDm event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError("You must be logged in to create an event.");
    }
    var collectionReference = getCollectionReference();
    var doc = collectionReference.doc();
    event.id = doc.id;
    event.userId = user.uid;
    await doc.set(event);
  }

  Stream<QuerySnapshot<EventDm>> getEventsStream({CategoryDm? category}) {
    Query<EventDm> query = getCollectionReference().orderBy("date");
    if (category != null && category.id != -1) {
      query = getCollectionReference()
          .where("categoryId", isEqualTo: category.id)
          .orderBy("date");
    }
    return query.snapshots();
  }

  Future<List<EventDm>> getEventsList(CategoryDm category) async {
    var collectionReference = getCollectionReference();
    var date = DateTime.now().dateOnly.millisecondsSinceEpoch;
    QuerySnapshot<EventDm> data;
    if (category.id == -1) {
      data = await collectionReference.where("date", isEqualTo: date).get();
    } else {
      data = await collectionReference
          .where("date", isEqualTo: date)
          .where("categoryId", isEqualTo: category.id)
          .get();
    }
    return data.docs.map((element) => element.data()).toList();
  }

  Future<void> updateEventLike(String uid, EventDm event) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid != uid) {
      throw StateError('Please log in to update favorites.');
    }
    await getCollectionReference().doc(event.id).update({
      'favoriteUsers': event.favoriteUsers.contains(uid)
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
    });
  }

  Stream<QuerySnapshot<EventDm>> getFavoriteStream(String uid) {
    return getCollectionReference()
        .where('favoriteUsers', arrayContains: uid)
        .snapshots();
  }

  @override
  Stream<EventDm?> watchEvent(String eventId) => getCollectionReference()
      .doc(eventId)
      .snapshots()
      .map((doc) => doc.data());

  @override
  Future<void> updateEvent(EventDm event) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Please log in to update an event.');
    }
    await getCollectionReference().doc(event.id).update({
      'title': event.title,
      'description': event.description,
      'date': event.date,
      'time': event.time,
      'categoryId': event.category.id,
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Please log in to delete an event.');
    }
    await getCollectionReference().doc(eventId).delete();
  }
}
