import 'dart:developer';
import 'package:frontend/data/person.dart';

import '../auth.dart';

final appPortalInstance = AppPortal()
  ..setJWTSub('jwt-sub-id123')
  ..setDigitalId('digital-id123')
  ..setUserPerson(
      Person(id: 2, jwt_sub_id: 'jwt-sub-id123',));

final appPortalPersonMetaDataInstance = AppPortalPersonMetaData()
  ..setGroups(['educator', 'teacher'])
  ..setScopes('address email');

class AppPortal {
  List<Person>? persons = [];
  Person userPerson = Person();
  String? user_jwt_sub;
  String? user_jwt_email;
  String? user_digital_id;
  AppPortalAuth? auth;
  bool signedIn = false;
  bool isTeacher = false;
  bool isGroupFetched = false;

  void setSignedIn(bool value) {
    signedIn = value;
  }

  bool getSignedIn() {
    return signedIn;
  }

  void setAuth(AppPortalAuth auth) {
    this.auth = auth;
  }

  AppPortalAuth? getAuth() {
    return this.auth;
  }

  Future<bool> getAuthSignedIn() async {
    final signedIn = await auth!.getSignedIn();
    return signedIn;
  }


  void setUserPerson(Person person) {
    userPerson = person;
  }

  Person getUserPerson() {
    return userPerson;
  }

  void setJWTSub(String? jwt_sub) {
    user_jwt_sub = jwt_sub;
  }

  String? getJWTSub() {
    return user_jwt_sub;
  }

  void setDigitalId(String? jwt_sub) {
    user_digital_id = jwt_sub;
  }

  String? getDigitalId() {
    return user_digital_id;
  }

  void setJWTEmail(String? jwt_email) {
    user_jwt_email = jwt_email;
  }

  String? getJWTEmail() {
    return user_jwt_email;
  }
 
  void setPersons(List<Person>? persons) {
    this.persons = persons;
  }

  void fetchPersonForUser() async {
    try {
      Person person = appPortalInstance.getUserPerson();
      if (person.digital_id == null ||
          person.digital_id != this.user_digital_id!) {
        person = await fetchPerson(this.user_digital_id!);
        this.userPerson = person;
        appPortalInstance.setUserPerson(person);

        if (person.digital_id != null) {
  
          this.isTeacher = appPortalPersonMetaDataInstance
              .getGroups()
              .contains('Educator');
          if (this.isTeacher ) {
            this.isGroupFetched = true;
          }

        }
      }
    } catch (e) {
      print(
          'Apps Portal fetchPersonForUser :: Error fetching person for user');
      print(e);
    }
  }

  void addPerson(Person person) {
    persons!.add(person);
  }

}

class AppPortalPersonMetaData {
  List<dynamic> _groups = [];
  String? _scopes;

  void setGroups(List<dynamic> groups) {
    _groups = groups;
  }

  List<dynamic> getGroups() {
    return this._groups;
  }

  void setScopes(String scopes) {
    _scopes = scopes;
  }

  List<String>? getScopes() {
    if (_scopes == null) {
      return null;
    }
    return _scopes!.split(' ');
  }
}
