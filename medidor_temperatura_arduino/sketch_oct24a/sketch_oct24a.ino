#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include "DHT.h"


// Configurações da rede Wi-Fi
const char* ssid = "WI-FI_CASA";
const char* password = "12345678";


//pinagem sensor
#define DHTPIN D3     
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Endpoint do servidor PHP
const char* serverName = "http://192.168.1.100/api/teste/inserir_temperatura.php";

// Criando um objeto WiFiClient
WiFiClient client;

// Simulando uma função para capturar a temperatura (você pode conectar um sensor real aqui)
float lerTemperatura() {
  return dht.readTemperature();
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  dht.begin();
  // Conectar ao Wi-Fi
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando ao Wi-Fi...");
  }

  Serial.println("Conectado ao Wi-Fi");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    
    // Preparando a temperatura para enviar
    float temperatura = lerTemperatura();
    Serial.print("Temperatura: ");
    Serial.print(temperatura);
    Serial.println(" *C "); 
    
    // Iniciando a conexão com o endpoint PHP, agora usando o WiFiClient
    http.begin(client, serverName);
    
    // Definindo o tipo de conteúdo
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    
    // Enviar a requisição POST com os dados
    String httpRequestData = "temperatura=" + String(temperatura);
    int httpResponseCode = http.POST(httpRequestData);
    
    // Verificando a resposta do servidor
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Resposta do servidor: " + response);
    } else {
      Serial.println("Erro ao enviar dados: " + String(httpResponseCode));
    }
    
    // Fechar a conexão HTTP
    http.end();
  } else {
    Serial.println("Erro de conexão Wi-Fi");
  }

  // Aguardar 5 segundos para a próxima leitura
  delay(10000);
}
