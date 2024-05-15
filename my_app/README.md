# CMSC 23 Week 9: User Authentication using Firebase

## Getting Started

Please follow the following steps:

- Fork this repository
- Clone the forked repository
- Set up Firebase and Cloud Firestore

## Introduction

This is a simple todo app that's connected to a Firebase Cloud Firestore. It can perform user authentication using Firebase.

## Folder Structure

```
lib
├───api
│   └───firebase_auth_api.dart*
│   └───firebase_todo_api.dart
├───models
│   └───todo_model.dart
├───pages
│   ├───home_page.dart
│   └───modal_todo.dart
│   └───signin_page.dart
│   └───signup_page.dart
│   └───todo_page.dart
│   └───user_details_page.dart
├───providers
│   └───auth_provider.dart*
│   └───todo_provider.dart
└───main.dart

* - to be added later
```

- Models - contains the data model used
- Pages - contains the pages/widgets used
- Providers - contains the Todo provider that contains the data and method logic
