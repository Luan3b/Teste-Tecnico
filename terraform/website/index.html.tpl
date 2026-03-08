<!DOCTYPE html>
<html>
<head>
<title>Arquivos S3</title>
<link rel="stylesheet" href="style.css">
</head>

<body>

<h1>Arquivos Gerados</h1>

<button onclick="buscar()">Ver arquivos</button>

<h2 id="total"></h2>

<ul id="lista"></ul>

<script>

const API = "http://BACKEND_ALB/files"

async function buscar(){

 const r = await fetch(API)
 const data = await r.json()

 document.getElementById("total").innerText =
  "Total de arquivos: " + data.total

 const lista = document.getElementById("lista")
 lista.innerHTML=""

 data.files.forEach(f=>{
   const li = document.createElement("li")
   li.innerText = f
   lista.appendChild(li)
 })

}

</script>

</body>
</html>