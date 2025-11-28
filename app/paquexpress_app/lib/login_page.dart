import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paquetes_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  // Controladores para los campos de texto
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool cargando = false;
  String mensajeError = "";

  // Función para hacer login
  Future<void> hacerLogin() async {
    setState(() {
      cargando = true;
      mensajeError = "";
    });

    try {
      // Llamar a la API de login
      var url = Uri.parse("http://localhost:8000/login/");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": usuarioController.text,
          "password": passwordController.text,
        }),
      );

      var decoded = utf8.decode(response.bodyBytes);
      var data = json.decode(decoded);

      if (response.statusCode == 200) {
        // Login exitoso - Ir a la página de paquetes
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaquetesPage(
              idUsuario: data['id_usuario'],
              nombreCompleto: data['nombre_completo'],
              username: data['username'],
            ),
          ),
        );
      } else {
        setState(() {
          mensajeError = data['detail'] ?? "Error al iniciar sesión";
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = "Error de conexión: $e";
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFFF8C42),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo o icono de la empresa
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 80,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Título
                  const Text(
                    "PAQUEXPRESS",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sistema de Entregas",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Tarjeta con formulario
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Campo de usuario
                          TextField(
                            controller: usuarioController,
                            decoration: InputDecoration(
                              labelText: "Usuario",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Campo de contraseña
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Botón de login
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: cargando ? null : hacerLogin,
                              child: cargando
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "INGRESAR",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Mensaje de error
                  if (mensajeError.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mensajeError,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 30),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}