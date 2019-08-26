var mongoose = require("mongoose");
var Schema = mongoose.Schema;

process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var config = require('../config');

// Bootstrap MongoDB connection
var dbMongo = mongoose.connect(config.dbMongo);

var LavadoModel = require("../../models/carwash");
var CarModel = require("../../models/car");
var ServiceModel = require("../../models/service");

var Cars = [
    {
        "img" : "CARRO.png",
        "price" : 50,
        "denomination" : "Auto"
    },
    {
        "img" : "CAMIONETA_CHICA.png",
        "price" : 60,
        "denomination" : "Camioneta"
    },
    {
        "img" : "CAMIONETA_GRANDE.png",
        "price" : 75,
        "denomination" : "Camioneta Gde"
    },
    {
        "img" : "CAMIONETA_GRANDE.png",
        "price" : 90,
        "denomination" : "Extra Grande"
    },
    {
        "img" : "TAXI.png",
        "price" : 40,
        "denomination" : "Taxi"
    },
    {
        "img" : "CARRO_FUERA.png",
        "price" : 40,
        "denomination" : "Auto X Fuera"
    },
    {
        "img" : "CAMIONETA_FUERA.png",
        "price" : 50,
        "denomination" : "Camioneta X Fuera"
    },
    {
        "img" : "MOTOCICLETA.png",
        "price" : 30,
        "denomination" : "Motocicleta"
    },
    {
        "img" : "SSP_CHICO.png",
        "price" : 30,
        "denomination" : "SSP Auto"
    },
    {
        "img" : "SSP_GRANDE.png",
        "price" : 35,
        "denomination" : "SSP Camioneta"
    },
    {
        "img" : "CARRO.png",
        "price" : 0,
        "denomination" : "No Paga"
    },
    {
        "img" : "CARRO.png",
        "price" : 40,
        "denomination" : "Estacionamiento"
    },
    {
        "img" : "CARRO.png",
        "price" : 50,
        "denomination" : "Estacionamiento Con Lavado"
    }
];

var Services = [
    {
        "img" : "SERVICIO1.png",
        "price" : 20,
        "denomination" : "Teef Auto"
    },
    {
        "img" : "SERVICIO1.png",
        "price" : 25,
        "denomination" : "Teef Camioneta",
    },
    {
        "img" : "SERVICIO1.png",
        "price" : 10,
        "denomination" : "Aspirado Cajuela"
    },
    {
        "img" : "SERVICIO1.png",
        "price" : 15,
        "denomination" : "Tolvas"
    },
    {
        "img" : "SERVICIO1.png",
        "price" : 0,
        "denomination" : "Estacionamiento"
    }
];

LavadoModel.find(function(err, Lavados) {
    if(err){
        console.log('Error',err);
    }
    Lavados.map(function(lavado){

        Cars.map(function(car){
            var NewCar = CarModel();
            NewCar.lavado_id = lavado._id;
			NewCar.denomination = car.denomination;
			NewCar.price = car.price;
			NewCar.img = car.img;
			NewCar.save();

        });

        Services.map(function(service){
            var NewService = ServiceModel();
            NewService.lavado_id = lavado._id;
            NewService.denomination = service.denomination;
            NewService.price = service.price;
            NewService.img = service.img;
            NewService.save();

        });

    });

});

console.log("DONE");
