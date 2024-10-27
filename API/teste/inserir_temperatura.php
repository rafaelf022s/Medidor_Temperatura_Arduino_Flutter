<?php
// Conexão com o banco de dados
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "bd_teste";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Obter o valor da temperatura do POST request
    $temperatura = $_POST['temperatura'];

    // Inserir o valor na tabela
    $sql = "INSERT INTO temperaturas (valor) VALUES ('$temperatura')";

    if ($conn->query($sql) === TRUE) {
        echo "Temperatura registrada com sucesso";
    } else {
        echo "Erro: " . $sql . "<br>" . $conn->error;
    }
}

$conn->close();
?>
