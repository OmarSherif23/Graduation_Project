class SocialUserModel {
  String? name;
  String? email;
  String? phone;
  String? uId;
  bool? isEmailVerified;
  String? image;
  String? cover;
  String? bio;
  bool? isBanned;
  int? ageCounter;
  int? religionCounter;
  int? genderCounter;
  int? ethnicityCounter;
  int? otherCounter;
  int? numberOfBans;
  int? sumOfCounters;
  DateTime? banEntTime;
  List<String>? interests; // Add interests property

  SocialUserModel({
    this.email,
    this.phone,
    this.name,
    this.uId,
    this.isEmailVerified,
    this.image,
    this.bio,
    this.cover,
    this.isBanned,
    this.ageCounter,
    this.religionCounter,
    this.genderCounter,
    this.ethnicityCounter,
    this.otherCounter,
    this.numberOfBans,
    this.sumOfCounters,
    this.banEntTime,
    this.interests, // Include interests in the constructor
  });

  SocialUserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    uId = json['uId'];
    image = json['image'];
    isEmailVerified = json['isEmailVerified'];
    bio = json['bio'];
    cover = json['cover'];
    isBanned = json['isBanned'];
    ageCounter = json['ageCounter'];
    religionCounter = json['religionCounter'];
    ethnicityCounter = json['ethnicityCounter'];
    genderCounter = json['genderCounter'];
    otherCounter = json['otherCounter'];
    numberOfBans = json['numberOfBans'];
    sumOfCounters = json['sumOfCounters'];
    banEntTime = json['banEntTime'];
    interests = List<String>.from(
        json['interests'] ?? []); // Deserialize interests list
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'uId': uId,
      'image': image,
      'bio': bio,
      'cover': cover,
      'banEntTime': banEntTime,
      'isEmailVerified': isEmailVerified,
      'isBanned': isBanned ?? false,
      'ageCounter': ageCounter ?? 0,
      'genderCounter': genderCounter ?? 0,
      'religionCounter': religionCounter ?? 0,
      'ethnicityCounter': ethnicityCounter ?? 0,
      'otherCounter': otherCounter ?? 0,
      'numberOfBans': numberOfBans ?? 0,
      'sumOfCounters': sumOfCounters ?? 0,
      'interests': interests ?? [], // Serialize interests list
    };
  }
}
