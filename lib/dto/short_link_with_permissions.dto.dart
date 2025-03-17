import 'user.dto.dart';

class ShortLinkWithPermissionsDto {
  final String id;
  final String longLink;
  final String shortKey;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;
  final bool isOwner;
  final bool canEdit;
  final UserDto user;

  ShortLinkWithPermissionsDto({
    required this.id,
    required this.longLink,
    required this.shortKey,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
    required this.isOwner,
    required this.canEdit,
    required this.user,
  });
}