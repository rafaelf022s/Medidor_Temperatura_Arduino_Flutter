<?php
// Conexão com o banco de dados
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "bd_teste";

// Criar a conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar se houve erro na conexão
if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

// Consultar a tabela de temperaturas
$sql = "SELECT id, valor, data_hora FROM temperaturas ORDER BY data_hora DESC";
$result = $conn->query($sql);

$temperaturas = array(); // Array para armazenar os dados

if ($result->num_rows > 0) {
    // Iterar sobre os resultados e adicionar ao array
    while($row = $result->fetch_assoc()) {
        $temperaturas[] = array(
            "id" => $row["id"],
            "valor" => $row["valor"],
            "data_hora" => $row["data_hora"]
        );
    }
    // Retornar os dados em formato JSON
    echo json_encode($temperaturas);
} else {
    // Caso não haja dados na tabela
    echo json_encode(array("mensagem" => "Nenhuma temperatura registrada"));
}

// Fechar a conexão com o banco de dados
$conn->close();
?>
