create database sistema;
use sistema;

create table Eventos(
IDEvento int primary key not null auto_increment,
nombre varchar(50) not null,
descripcion varchar(50) not null,
fechaInicio datetime not null,
fechaFin datetime not null,
ubicacion varchar(25) not null,
estado enum("planeado","en curso","finalizado")
);

create table Asistentes(
IDAsistente int primary key not null auto_increment,
nombreC varchar(50) not null,
correo varchar(20) not null,
telefono int(10) not null
);

create table Asistencia(
IDEvento int not null,
IDAsistente int not null,
primary key (IDEvento,IDAsistente),
foreign key (IDEvento) references Eventos(IDEvento),
foreign key (IDAsistente) references Asistentes(IDAsistente)
);

create table Logistica(
IDLogistica int primary key not null auto_increment,
IDEvento int not null,
estado enum("confirmado","pendiente","cancelado"),
foreign key (IDEvento) references Eventos(IDEvento)
);

#1) Es necesario llevar un registro de las asistencias a los distintos eventos, que incluya los datos del evento y los asistentes

select * 
from Asistencia a
join Eventos e on a.IDEvento = e.IDEvento
join Asistentes asis on a.IDAsistente = asis.IDAsistente;

#2) La empresa solicita controlar que la fecha fin de evento no sea antes de la fecha de inicio. Aplicar restricciones para mantener la integridad en los datos.

ALTER TABLE Eventos 
ADD CONSTRAINT CHK_Fecha CHECK (fechaFin > fechaInicio);

#3) Implementar un trigger que asigne automáticamente el estado “Planeado” a un nuevo evento.

create trigger autoPlaneado
before insert on Eventos
for each row
set new.estado = "planeado";

#4) Implementar un trigger que registre la eliminación de un evento en la tabla de auditoría AuditoriaEliminaciones, incluirá el id del evento eliminado, el nombre del evento y la fecha de eliminación.

create table AuditoriaEliminaciones
(IDEvento int not null,
nombre varchar(50) not null,
fechaEliminacion datetime
);

create trigger elimiEvento
after delete on Eventos
for each row
insert into AuditoriaEliminaciones (IDEvento,nombre,fechaEliminacion) values (old.IDEvento, old.nombre, now());

#5) Crear una vista que muestre el nombre del cliente, el nombre y fecha del evento.

create view vistaInfo as
select asis.nombreC, e.nombre,e.fechaInicio
from Asistencia a
join Eventos e on a.IDEvento = e.IDEvento
join Asistentes asis on a.IDAsistente = asis.IDAsistente;

select * from vistaInfo; 

#6) Crear un usuario que tenga acceso solo a la vista creada en el ítem

create user "vista"@"localhost" identified by "siu";
grant select on vistaInfo to "vista"@"localhost";

#7)  Crear una función que calcule y devuelva el número total de asistentes registrados para un evento específico (la función recibe como parámetro el id del evento).


Delimiter $$
create function numeroTotal(id int) returns int
begin
declare total int;
select count(*) into total
from Asistencia
where IDEvento = id;
return total;
end;

select numeroTotal(1);












