-- Migrations will appear here as you chat with AI

create table chapters (
  id bigint primary key generated always as identity,
  name text not null,
  description text
);

create table tariff_headings (
  id bigint primary key generated always as identity,
  chapter_id bigint references chapters (id),
  code text not null unique,
  description text
);

create table users (
  id bigint primary key generated always as identity,
  username text not null unique,
  password text not null,
  role text check (role in ('admin', 'customs_agent')) not null
);

create table imports (
  id bigint primary key generated always as identity,
  tariff_heading_id bigint references tariff_headings (id),
  user_id bigint references users (id),
  import_date date not null,
  quantity numeric not null,
  value numeric not null
);

alter table chapters
rename to capitulos;

alter table tariff_headings
rename to partidas_arancelarias;

alter table users
rename to usuarios;

alter table imports
rename to importaciones;

alter table partidas_arancelarias
rename column chapter_id to capitulo_id;

alter table importaciones
rename column tariff_heading_id to partida_arancelaria_id;

alter table importaciones
rename column user_id to usuario_id;

alter table capitulos
rename column name to nombre;

alter table capitulos
rename column description to descripcion;

alter table partidas_arancelarias
rename column code to codigo;

alter table partidas_arancelarias
rename column description to descripcion;

alter table usuarios
rename column username to nombre_usuario;

alter table usuarios
rename column password to contrasena;

alter table usuarios
rename column role to rol;

alter table importaciones
rename column import_date to fecha_importacion;

alter table importaciones
rename column quantity to cantidad;

alter table importaciones
rename column value to valor;

create table subpartidas_arancelarias (
  id bigint primary key generated always as identity,
  partida_arancelaria_id bigint references partidas_arancelarias (id),
  codigo text not null unique,
  descripcion text
);