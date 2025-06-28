// To parse this JSON data, do
//
//     final competetionsResponse = competetionsResponseFromJson(jsonString);

import 'dart:convert';

CompetetionsResponse competetionsResponseFromJson(String str) => CompetetionsResponse.fromJson(json.decode(str));

String competetionsResponseToJson(CompetetionsResponse data) => json.encode(data.toJson());

class CompetetionsResponse {
    int count;
    Filters filters;
    List<Competition> competitions;

    CompetetionsResponse({
        required this.count,
        required this.filters,
        required this.competitions,
    });

    factory CompetetionsResponse.fromJson(Map<String, dynamic> json) => CompetetionsResponse(
        count: json["count"],
        filters: Filters.fromJson(json["filters"]),
        competitions: List<Competition>.from(json["competitions"].map((x) => Competition.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "filters": filters.toJson(),
        "competitions": List<dynamic>.from(competitions.map((x) => x.toJson())),
    };
}

class Competition {
    int id;
    Area area;
    String name;
    String code;
    Type type;
    String emblem;
    Plan plan;
    CurrentSeason currentSeason;
    int numberOfAvailableSeasons;
    DateTime lastUpdated;

    Competition({
        required this.id,
        required this.area,
        required this.name,
        required this.code,
        required this.type,
        required this.emblem,
        required this.plan,
        required this.currentSeason,
        required this.numberOfAvailableSeasons,
        required this.lastUpdated,
    });

    factory Competition.fromJson(Map<String, dynamic> json) => Competition(
        id: json["id"],
        area: Area.fromJson(json["area"]),
        name: json["name"],
        code: json["code"],
        type: typeValues.map[json["type"]]!,
        emblem: json["emblem"],
        plan: planValues.map[json["plan"]]!,
        currentSeason: CurrentSeason.fromJson(json["currentSeason"]),
        numberOfAvailableSeasons: json["numberOfAvailableSeasons"],
        lastUpdated: DateTime.parse(json["lastUpdated"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "area": area.toJson(),
        "name": name,
        "code": code,
        "type": typeValues.reverse[type],
        "emblem": emblem,
        "plan": planValues.reverse[plan],
        "currentSeason": currentSeason.toJson(),
        "numberOfAvailableSeasons": numberOfAvailableSeasons,
        "lastUpdated": lastUpdated.toIso8601String(),
    };
}

class Area {
    int id;
    String name;
    String code;
    String? flag;

    Area({
        required this.id,
        required this.name,
        required this.code,
        required this.flag,
    });

    factory Area.fromJson(Map<String, dynamic> json) => Area(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        flag: json["flag"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "flag": flag,
    };
}

class CurrentSeason {
    int id;
    DateTime startDate;
    DateTime endDate;
    int currentMatchday;
    Winner? winner;

    CurrentSeason({
        required this.id,
        required this.startDate,
        required this.endDate,
        required this.currentMatchday,
        required this.winner,
    });

    factory CurrentSeason.fromJson(Map<String, dynamic> json) => CurrentSeason(
        id: json["id"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        currentMatchday: json["currentMatchday"],
        winner: json["winner"] == null ? null : Winner.fromJson(json["winner"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "startDate": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "currentMatchday": currentMatchday,
        "winner": winner?.toJson(),
    };
}

class Winner {
    int id;
    String name;
    String shortName;
    String tla;
    String crest;
    String address;
    String website;
    int founded;
    String clubColors;
    String venue;
    DateTime lastUpdated;

    Winner({
        required this.id,
        required this.name,
        required this.shortName,
        required this.tla,
        required this.crest,
        required this.address,
        required this.website,
        required this.founded,
        required this.clubColors,
        required this.venue,
        required this.lastUpdated,
    });

    factory Winner.fromJson(Map<String, dynamic> json) => Winner(
        id: json["id"],
        name: json["name"],
        shortName: json["shortName"],
        tla: json["tla"],
        crest: json["crest"],
        address: json["address"],
        website: json["website"],
        founded: json["founded"],
        clubColors: json["clubColors"],
        venue: json["venue"],
        lastUpdated: DateTime.parse(json["lastUpdated"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "shortName": shortName,
        "tla": tla,
        "crest": crest,
        "address": address,
        "website": website,
        "founded": founded,
        "clubColors": clubColors,
        "venue": venue,
        "lastUpdated": lastUpdated.toIso8601String(),
    };
}

enum Plan {
    TIER_FOUR,
    TIER_ONE
}

final planValues = EnumValues({
    "TIER_FOUR": Plan.TIER_FOUR,
    "TIER_ONE": Plan.TIER_ONE
});

enum Type {
    CUP,
    LEAGUE
}

final typeValues = EnumValues({
    "CUP": Type.CUP,
    "LEAGUE": Type.LEAGUE
});

class Filters {
    String client;

    Filters({
        required this.client,
    });

    factory Filters.fromJson(Map<String, dynamic> json) => Filters(
        client: json["client"],
    );

    Map<String, dynamic> toJson() => {
        "client": client,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
