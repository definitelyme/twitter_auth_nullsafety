part of twitter_auth_null_safety_impl.dart;

class TwitterUser {
  const TwitterUser._({this.id, this.userId, this.email, this.username});

  /// User's unique Identifier
  final String? id;

  /// The user's unique identifier, usually a long series of numbers.
  final String? userId;

  /// The user's Twitter handle.
  ///
  /// For example, if you can visit your Twitter profile by typing the URL
  /// http://twitter.com/hello, your Twitter handle (or username) is "hello".
  final String? username;

  /// The email address assciated with the user.
  ///
  /// Will return null if "Request email addresses from users"
  /// is disabled for your Twitter app (https://apps.twitter.com)
  final String? email;

  static TwitterUser fromMap(Map<String, dynamic> map) {
    return TwitterUser._(
      id: map['id'],
      userId: map['user_id'],
      email: map['email'],
      username: map['username'],
    );
  }

  @override
  bool operator ==(other) =>
      other is TwitterUser &&
      other.id == id &&
      other.userId == userId &&
      other.email == email &&
      other.username == username;

  @override
  int get hashCode =>
      id.hashCode ^ userId.hashCode ^ email.hashCode ^ username.hashCode;

  @override
  String toString() =>
      'User(id: $id, userId: $userId, email: $email, username: $username)';
}
