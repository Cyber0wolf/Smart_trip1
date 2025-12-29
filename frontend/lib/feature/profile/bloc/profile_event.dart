import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? username;
  final String? firstName;
  final String? lastName;

  const UpdateProfile({
    this.username,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [username, firstName, lastName];
}








