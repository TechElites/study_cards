<?php
$servername = "localhost";
$username = "studycards";
$password = "";
$dbname = "my_studycards";

// Creare connessione
$conn = new mysqli($servername, $username, $password, $dbname);

// Controllare la connessione
if ($conn->connect_error) {
    die("Connessione fallita: " . $conn->connect_error);
}

// Ricevere dati POST
$content = $_POST['content'];

// Preparare e eseguire la query
$sql = "INSERT INTO feedback (content) VALUES ('$content')";

if ($conn->query($sql) === TRUE) {
    echo "Nuovo record inserito con successo";
} else {
    echo "Errore: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
