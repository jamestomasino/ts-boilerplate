class Page {
    constructor(public name) { }
    info(desc) {
        console.log(this.name + " is " + desc);
    }
}
var page1:Page = new Page("Page1")
page1.info("quirky")
