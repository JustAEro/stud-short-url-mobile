class UserDto {
  final String login;
  final String id;
  final String? accessToken;

  UserDto({required this.login, required this.id, this.accessToken});
}
