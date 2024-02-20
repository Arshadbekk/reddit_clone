class Community {
  final String id;
  final String name;
  final String banner;
  final String avatar;
  final List<String> member;
  final List<String> mods;

  Community({
    required this.id,
    required this.name,
    required this.banner,
    required this.avatar,
    required this.member,
    required this.mods,
  });

  Community copyWith({
    String? id,
    String? name,
    String? banner,
    String? avatar,
    List<String>? member,
    List<String>? mods,
  }) {
    return Community(
        id: id ?? this.id,
        name: name ?? this.name,
        banner: banner ?? this.banner,
        avatar: avatar ?? this.avatar,
        member: member ?? this.member,
        mods: mods ?? this.mods);
  }

  Map<String,dynamic>toJson(){
    return {
      "name":name,
      "id":id,
      "banner":banner,
      "avatar":avatar,
      "member":member,
      "mods":mods,
    };
  }

  factory Community.fromJson(Map<String,dynamic> json){
    return Community(
        id: json["id"],
        name: json["name"],
        banner: json["banner"],
        avatar: json["avatar"],
        member: List<String>.from(json["member"]),
        mods:List<String>.from( json["mods"])
    );
  }

}
