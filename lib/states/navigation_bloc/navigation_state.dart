part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

final class Assistant extends NavigationState {
  const Assistant();
}

final class ProjectsList extends NavigationState {
  const ProjectsList();
}

final class Authentication extends NavigationState {
  const Authentication();
}

final class TestComponents extends NavigationState {
  const TestComponents();
}

final class ChangePassword extends NavigationState {
  const ChangePassword();
}

final class Home extends NavigationState {
  const Home();
}

final class Profile extends NavigationState {
  const Profile();
}

final class Settings extends NavigationState {
  const Settings();
}

final class Splash extends NavigationState {
  const Splash();
}

final class TaskList extends NavigationState {
  const TaskList();
}

final class SubTaskDetail extends NavigationState {
  const SubTaskDetail();
}

final class ProjectDetail extends NavigationState {
  const ProjectDetail();
}

final class UserProjectInvitation extends NavigationState {
  const UserProjectInvitation();
}

final class SubTaskCreate extends NavigationState {
  const SubTaskCreate();
}