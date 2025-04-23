class UserListWithRole {
  int? Id;
  int? RoleId;

  UserListWithRole({this.Id, this.RoleId});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.Id;
    data['RoleId'] = this.RoleId;
    return data;
  }
}
