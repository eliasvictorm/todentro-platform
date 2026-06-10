class Event {
  final int? id;
  final String name;
  final String? description;
  final String date;
  final String time;
  final String location;
  final int maxParticipants;
  final String category;
  final int participantCount;
  final int availableSlots;
  final String? coverImageUrl;
  final String? inviteToken;
  final String? ownerName;
  final int? ownerId;

  Event({
    this.id,
    required this.name,
    this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.maxParticipants,
    required this.category,
    this.participantCount = 0,
    this.availableSlots = 0,
    this.coverImageUrl,
    this.inviteToken,
    this.ownerName,
    this.ownerId,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        date: _parseDate(json['date']),
        time: _parseTime(json['time']),
        location: json['location'] ?? '',
        maxParticipants: json['maxParticipants'] ?? 0,
        category: json['category'] ?? 'Outro',
        participantCount: json['participantCount'] ?? 0,
        availableSlots: json['availableSlots'] ?? 0,
        coverImageUrl: json['coverImageUrl'],
        inviteToken: json['inviteToken'],
        ownerName: json['ownerName'],
        ownerId: json['ownerId'],
      );

  static String _parseDate(dynamic raw) {
    if (raw == null) return '';
    if (raw is List) {
      return '${raw[0].toString().padLeft(4, '0')}-'
          '${raw[1].toString().padLeft(2, '0')}-'
          '${raw[2].toString().padLeft(2, '0')}';
    }
    final s = raw.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  static String _parseTime(dynamic raw) {
    if (raw == null) return '00:00';
    if (raw is List) {
      return '${raw[0].toString().padLeft(2, '0')}:'
          '${raw[1].toString().padLeft(2, '0')}';
    }
    final s = raw.toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'date': date,
        'time': time.length == 5 ? '$time:00' : time,
        'location': location,
        'maxParticipants': maxParticipants,
        'category': category,
        'coverImageUrl': coverImageUrl,
      };

  bool hasAvailableSlots() => availableSlots > 0;
}

class Participant {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  bool paid;

  Participant({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.paid = false,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        paid: json['paid'] ?? false,
      );

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'phone': phone};
}

class Invite {
  final int id;
  final String status;
  final String inviterName;
  final String inviterEmail;
  final int eventId;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventCategory;
  final String? eventCoverImageUrl;
  final String createdAt;

  Invite({
    required this.id,
    required this.status,
    required this.inviterName,
    required this.inviterEmail,
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventCategory,
    this.eventCoverImageUrl,
    required this.createdAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) => Invite(
        id: json['id'],
        status: json['status'] ?? 'PENDING',
        inviterName: json['inviterName'] ?? '',
        inviterEmail: json['inviterEmail'] ?? '',
        eventId: json['eventId'],
        eventName: json['eventName'] ?? '',
        eventDate: Event._parseDate(json['eventDate']),
        eventTime: Event._parseTime(json['eventTime']),
        eventLocation: json['eventLocation'] ?? '',
        eventCategory: json['eventCategory'] ?? 'Outro',
        eventCoverImageUrl: json['eventCoverImageUrl'],
        createdAt: json['createdAt'] ?? '',
      );
}

class AppUser {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  AppUser({required this.id, required this.name, required this.email, this.avatarUrl});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatarUrl'],
      );
}

class ChecklistItem {
  final String id;
  String task;
  String assignedTo;
  bool done;

  ChecklistItem({
    required this.id,
    required this.task,
    this.assignedTo = 'Em aberto',
    this.done = false,
  });
}
