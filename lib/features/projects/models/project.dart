import 'dart:convert';

class ProjectMember {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;

  ProjectMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  factory ProjectMember.fromMap(Map<String, dynamic> map) {
    return ProjectMember(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}

class ProjectTask {
  final String id;
  final String title;
  bool isCompleted;
  final String dueDate;
  final String assigneeName;
  String priority;
  String status;
  String meetingInfo;
  String usefulLinks;
  String attachedFileName;

  ProjectTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    required this.assigneeName,
    this.priority = 'Haute priorité',
    this.status = 'todo',
    this.meetingInfo = '',
    this.usefulLinks = '',
    this.attachedFileName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate,
      'assigneeName': assigneeName,
      'priority': priority,
      'status': status,
      'meetingInfo': meetingInfo,
      'usefulLinks': usefulLinks,
      'attachedFileName': attachedFileName,
    };
  }

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] ?? '',
      assigneeName: map['assigneeName'] ?? '',
      priority: map['priority'] ?? 'Haute priorité',
      status: map['status'] ?? 'todo',
      meetingInfo: map['meetingInfo'] ?? '',
      usefulLinks: map['usefulLinks'] ?? '',
      attachedFileName: map['attachedFileName'] ?? '',
    );
  }
}

class ProjectMilestone {
  final String id;
  final String title;
  final String dueDate;
  bool isReached;

  ProjectMilestone({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isReached = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate,
      'isReached': isReached,
    };
  }

  factory ProjectMilestone.fromMap(Map<String, dynamic> map) {
    return ProjectMilestone(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      dueDate: map['dueDate'] ?? '',
      isReached: map['isReached'] ?? false,
    );
  }
}

class VoiceNote {
  final String id;
  String title;
  final String filePath;
  final Duration duration;
  final String createdAt;
  final String createdBy;

  VoiceNote({
    required this.id,
    required this.title,
    required this.filePath,
    required this.duration,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'durationMs': duration.inMilliseconds,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  factory VoiceNote.fromMap(Map<String, dynamic> map) {
    return VoiceNote(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      filePath: map['filePath'] ?? '',
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      createdAt: map['createdAt'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }
}

class ProjectFile {
  final String id;
  final String name;
  final String type; // 'pdf', 'image', 'code', 'other'
  final String uploadedBy;
  final String uploadedAt;
  final String? path;

  ProjectFile({
    required this.id,
    required this.name,
    required this.type,
    required this.uploadedBy,
    required this.uploadedAt,
    this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
      'path': path,
    };
  }

  factory ProjectFile.fromMap(Map<String, dynamic> map) {
    return ProjectFile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'other',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: map['uploadedAt'] ?? '',
      path: map['path'],
    );
  }
}

class Project {
  final String id;
  final String userId;
  String title;
  String description;
  String objectives;
  String level; // Débutant, Intermédiaire, Avancé
  String category; // Bras Robotique, Robotique mobile, IoT & Domotique, etc.
  String visibility; // Privé, Équipe, Public
  String status; // En cours, En pause, Terminé
  String dueDate;
  String? imagePath;
  bool isJoined;
  final List<ProjectMember> members;
  final List<ProjectTask> tasks;
  final List<ProjectMilestone> milestones;
  final List<ProjectFile> files;
  final List<VoiceNote> voiceNotes;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.objectives,
    required this.level,
    required this.category,
    required this.visibility,
    this.status = 'En cours',
    this.dueDate = '30 nov. 2025',
    this.imagePath,
    this.isJoined = false,
    required this.members,
    required this.tasks,
    required this.milestones,
    List<ProjectFile>? files,
    List<VoiceNote>? voiceNotes,
  })  : files = files ?? [],
        voiceNotes = voiceNotes ?? [];

  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  int get pendingTasksCount => tasks.where((t) => !t.isCompleted).length;

  int get reachedMilestonesCount =>
      milestones.where((m) => m.isReached).length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'objectives': objectives,
      'level': level,
      'category': category,
      'visibility': visibility,
      'status': status,
      'dueDate': dueDate,
      'imagePath': imagePath,
      'isJoined': isJoined,
      'members': members.map((m) => m.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'files': files.map((f) => f.toMap()).toList(),
      'voiceNotes': voiceNotes.map((v) => v.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '1',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      objectives: map['objectives'] ?? '',
      level: map['level'] ?? 'Débutant',
      category: map['category'] ?? 'Autre',
      visibility: map['visibility'] ?? 'Public',
      status: map['status'] ?? 'En cours',
      dueDate: map['dueDate'] ?? '30 nov. 2025',
      imagePath: map['imagePath'],
      isJoined: map['isJoined'] ?? false,
      members: (map['members'] as List<dynamic>?)
              ?.map((m) => ProjectMember.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => ProjectTask.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      milestones: (map['milestones'] as List<dynamic>?)
              ?.map((m) => ProjectMilestone.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      files: (map['files'] as List<dynamic>?)
              ?.map((f) => ProjectFile.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      voiceNotes: (map['voiceNotes'] as List<dynamic>?)
              ?.map((v) => VoiceNote.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
