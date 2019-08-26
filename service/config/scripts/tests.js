var request = require('request');
var moment = require('moment');

var Timer = setInterval(InsertTicket, 10000);
var MaxTickets = 10000;
var currentTickets = 0;

function InsertTicket() {
    var header = {
        Authorization: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJsYXZhZG9faWQiOlt7Il9pZCI6IjU2YTQxOWY5Zjc0NjA1N2UyNzkxNjU4OCIsIl9fdiI6MTUsInVzZXJzIjpbIjU2YTk5NzgxZGYwZWNjMGQxNzUxYWJlZiIsIjU2YTk5N2FmZGYwZWNjMGQxNzUxYWJmMCIsIjU2YTk5N2MxZGYwZWNjMGQxNzUxYWJmMSIsIjU2YTk5N2Q2ZGYwZWNjMGQxNzUxYWJmMiIsIjU3MzE1ZTBlNDk5ZTYyMDkwNTVhNTJjZCIsIjU3MzE1ZTMwNDk5ZTYyMDkwNTVhNTJjZSIsIjU3MzE1ZTQ5NDk5ZTYyMDkwNTVhNTJjZiIsIjU3MzE1ZTVmNDk5ZTYyMDkwNTVhNTJkMCIsIjU2YTQxYTE2Zjc0NjA1N2UyNzkxNjU4OSJdLCJzdGF0dXMiOnRydWUsImNyZWF0ZWQiOiIyMDE2LTAxLTIyVDExOjM3OjQwLjk2M1oiLCJpbmZvIjp7InR5cGUiOiIxIiwiYWRkcmVzcyI6IkVtaWxpbyBDYXJyYW56YSAjMTEzIENvbC4gQWxiZXJ0LCBDLlAuIDAzNTYwLiBFc3EuIFBsdXRhcmNvIEUuIENhbGxlcy4iLCJwaG9uZSI6IjAwMDAwMDAwMDAiLCJuYW1lIjoiUGx1dGFyY28ifX0seyJfaWQiOiI1NzMxNWNhZDQ5OWU2MjA5MDU1YTUyY2IiLCJfX3YiOjEsInVzZXJzIjpbIjU2YTQxYTE2Zjc0NjA1N2UyNzkxNjU4OSJdLCJzdGF0dXMiOnRydWUsImNyZWF0ZWQiOiIyMDE2LTA1LTEwVDAzOjU4OjIzLjMzOVoiLCJpbmZvIjp7InR5cGUiOiIxIiwiYWRkcmVzcyI6IkNvbGluYXMgZGVsIFN1ciIsInBob25lIjoiNzk4MjM3NDk4MjMiLCJuYW1lIjoiQ29saW5hcyJ9fV0sInVzZXJfaWQiOiI1NmE0MWExNmY3NDYwNTdlMjc5MTY1ODkiLCJ1c2VyX3VzZXJuYW1lIjoiam9zZSIsInJvbCI6IkFkbWluaXN0cmFkb3IiLCJpYXQiOjE0NjQ1MDY4NjMsImV4cCI6MTQ2NDY3OTY2M30.8e5TITurDVMPZ2RXZHRpJ5qpia3fa1sNBr7j2Pk0cG4"

    }
    var NewTicket = {

        lavado_id: "56a419f9f746057e27916588",
        corte_id: 189,
        order_id: "#SomeNumber",
        status: "Charged",
        user: 'Jose Garfias',
        entryDate: moment().format(),
        exitDate: moment().add(50,'seconds').format(),
        washingTime: "00:05",
        total: 10,
        car: {
            denomination: 'carBot',
            price: '8'
        },
        services: [
            {
                denomination: 'serviceonebot',
                price: '1'
            },
            {
                denomination: 'servicetwobot',
                price: '1'
            }
        ]
    }

    if(currentTickets < MaxTickets) {
        request.post({
            url:'http://159.203.118.233:3000/ticket',
            headers: header,
            json: NewTicket
        },function(err,httpResponse,body){
            console.log('Added: #' + currentTickets);
            if (httpResponse) {
                console.log(httpResponse.body.message);

            }
            currentTickets += 1;
        })
    }else{
        console.log("All tickets Added, (Deberia estar apagado :P).");
    }

}
