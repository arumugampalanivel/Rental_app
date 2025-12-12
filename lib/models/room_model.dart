class RoomModel {
  final int? id;
  final String roomNo;
  final String floor;
  final String location;
  final double advance;
  final String rent;
  final int maxOccupants;
  final String notes;
  final String status;

  RoomModel({
    this.id,
    required this.roomNo,
    required this.floor,
    required this.location,
    required this.advance,
    required this.rent,
    required this.maxOccupants,
    required this.notes,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "floor": floor,
      "room_no": roomNo,
      "location": location,
      "advance": advance,
      "rent": rent,
      "max_occupants": maxOccupants,
      "notes": notes,
      "status": status,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map["id"],
      roomNo: map["room_no"] ?? "",
      floor: map["floor"] ?? "",
      location: map["location"] ?? "",
      advance: (map["advance"] ?? 0).toDouble(),
      rent: map["rent"] ?? "",
      maxOccupants: map["max_occupants"] ?? 0,
      notes: map["notes"] ?? "",
      status: map["status"] ?? "Available",
    );
  }
}
