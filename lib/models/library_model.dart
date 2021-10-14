import 'package:flutter/material.dart';

class LibraryModel {
  LibraryModel({
    Key? key,
    required this.systemName,
    required this.shortName,
    required this.formalName,
    required this.urlPc,
    required this.address,
    required this.pref,
    required this.city,
    required this.post,
    required this.tel,
    required this.geocode,
    required this.category,
    required this.systemId,
    required this.libkey,
    required this.distance,
    this.image,
    this.status,
    this.bookPageURL,
  });

  final String systemId;
  final String systemName;
  final String libkey;
  final String shortName;
  final String formalName;
  final String urlPc;
  final String address;
  final String pref;
  final String city;
  final String post;
  final String tel;
  final String geocode;
  final String category;
  final double distance;
  String? image;
  Map<String, dynamic>? status;
  String? bookPageURL;
}
