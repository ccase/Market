using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "Market"
    summary = ""
    srcDirs = [`fan/`]
    resDirs = [`res/`]
    depends = ["sys 1.0"]
  }
}
