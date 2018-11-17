class Example {
    constructor(public name) { }
    dance(speed) {
        console.log(this.name + " danced " + speed);
    }
}
var bjorn:Example = new Example("Bjorn the bear")
bjorn.dance("fast")
