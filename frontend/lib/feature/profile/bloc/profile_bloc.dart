import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'profile_event.dart';
import 'profile_state.dart';
import '../data/profile_api.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileApi profileApi;

  ProfileBloc(this.profileApi) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await profileApi.getProfile();
      emit(ProfileLoaded(profile));
    } on DioException catch (e) {
      String msg = 'Failed to load profile';
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 404) {
          msg = 'Profile endpoint not found (404). Please restart the Django server.';
        } else if (statusCode == 401) {
          msg = 'Authentication required. Please log in again.';
        } else if (statusCode == 403) {
          msg = 'Access denied. Please check your permissions.';
        } else {
          final data = e.response!.data;
          if (data is Map) {
            msg = data.toString();
          } else if (data is String) {
            // If it's HTML, extract a simple message
            if (data.contains('not found')) {
              msg = 'Endpoint not found. Please restart the Django server.';
            } else {
              msg = data;
            }
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        msg = 'Connection timeout. Is the server running?';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'Cannot connect to server. Is the server running on port 8000?';
      }
      emit(ProfileError(msg));
    } catch (_) {
      emit(const ProfileError('Failed to load profile'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    Map<String, dynamic> currentProfile = {};

    if (currentState is ProfileLoaded) {
      currentProfile = Map<String, dynamic>.from(currentState.profile);
      emit(ProfileUpdating(currentProfile));
    } else {
      emit(ProfileLoading());
    }

    try {
      final updatedProfile = await profileApi.updateProfile(
        username: event.username,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(ProfileLoaded(updatedProfile));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? 'Failed to update profile';
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(currentState.profile));
      } else {
        emit(ProfileError(msg));
      }
      rethrow;
    } catch (_) {
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(currentState.profile));
      } else {
        emit(const ProfileError('Failed to update profile'));
      }
      rethrow;
    }
  }
}

