var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var StockSchema = new Schema({

	lavado_id: { 
		type: Schema.ObjectId, 
		ref: 'Carwash',
		required: true 
	},
	product: {
		denomination: {type: String},
		quantity: {type: Number},
		price: {type: Number}
	},
	min: {
		type: Number,
		default: 3
	},
	deliverDate:{
		type: Date
	},
	total:{
		type: Number
	},
    created: {
        type: Date,
        default: Date.now
    }

});

//Return the module
module.exports = mongoose.model("Stock",StockSchema);
