class ProjectMember {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;

  const ProjectMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl = '',
  });
}

class ProjectTask {
  final String id;
  final String title;
  bool isCompleted;
  final String dueDate;
  final String assigneeName;

  ProjectTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    required this.assigneeName,
  });
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
}

class Project {
  final String id;
  final String title;
  final String description;
  final String objectives;
  final String level; // Débutant, Intermédiaire, Avancé
  final String category; // Robotique mobile, IoT & Domotique, Électronique, etc.
  final String visibility; // Privé, Équipe, Public
  final String status; // En cours, En pause, Terminé
  final String dueDate;
  final String? imagePath;
  bool isJoined;
  final List<ProjectMember> members;
  final List<ProjectTask> tasks;
  final List<ProjectMilestone> milestones;

  Project({
    required this.id,
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
  });

  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / tasks.length;
  }
}
