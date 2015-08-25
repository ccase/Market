using build

class Build : BuildPod {

    new make() {
        podName = "Market"
        summary = ""
        srcDirs = [`fan/`]
        depends = ["sys 1.0+"]
    }


    @Target { help = "Build my jar file" }
    Void buildJar() {
        JarDist(this) {
            mainMethod      = "Market::Meta.main"
            mainMethodArg   = true
            outFile         = File(`/c:/Users/ccase/Market.jar`)
            podNames        = ["Market"]
        }.run
    }
}