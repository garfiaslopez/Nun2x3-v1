
var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var InsumoSchema = new Schema({

	denomination:{
		type: String, 
		default: "Sin Descripcion",
		required: true
	},
	price:{
		type: Number,
		default: 0.00
	},
	img:{
		type: String,
		default: "../src/images/defaultproduct.jpg"
	},
    created: {
        type: Date,
        default: Date.now()
    }

});

//Return the module
module.exports = mongoose.model("Product",InsumoSchema);