import 'package:flutter/material.dart';

class CategoryDm {
  int id;
  String imagePath;
  IconData icon;

  CategoryDm(this.id, this.imagePath, this.icon);
}

List<CategoryDm> categoriesList = [
  CategoryDm(1, 'assets/categories/Sport.png', Icons.motorcycle_rounded),
  CategoryDm(2, 'assets/categories/birthday.png', Icons.cake),
  CategoryDm(3, 'assets/categories/meeting.png', Icons.people_alt),
  CategoryDm(4, 'assets/categories/gaming.png', Icons.videogame_asset),
  CategoryDm(5, 'assets/categories/eating.png', Icons.restaurant),
  CategoryDm(6, 'assets/categories/holiday.png', Icons.beach_access),
  CategoryDm(7, 'assets/categories/exhibition.png', Icons.brush),
  CategoryDm(8, 'assets/categories/workshop.png', Icons.build),
  CategoryDm(9, 'assets/categories/book_club.png', Icons.menu_book),
];
