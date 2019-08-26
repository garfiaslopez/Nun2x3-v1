var mongoose = require("mongoose");
var mongoosePaginate = require('mongoose-paginate');

var Schema = mongoose.Schema;

var TicketSchema = new Schema({

	lavado_id: {
		type: Schema.ObjectId,
		ref: 'Carwash',
		required: true
	},
	order_id:{
		type: String
	},
	corte_id:{
		type: String
	},
	status: {
		type: String
	},
	user:{
		type: String
	},
	car: {
		denomination: {type:String},
		price: {type :Number}
	},
	services: [{
		denomination: {type:String},
		price:{type:Number}
	}],
	entryDate: {
        type: String
    },
    exitDate: {
        type: String
    },
	washingTime: {
		type: String
	},
	total: {
		type: Number
	},
	date:{
		type: Date
	},
	created: {
		type: Date,
		default: Date.now
	}
});

TicketSchema.plugin(mongoosePaginate);
//Return the module
module.exports = mongoose.model("Ticket",TicketSchema);
