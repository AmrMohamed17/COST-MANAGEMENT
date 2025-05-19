class Client {
  final String id;
  final String name;
  String? email; // Option
  
  Client({required this.id, required this.name, this.email});

  @override
  String toString() {
    return 'Client(id: $id, name: $name, email: $email)';
  }
}