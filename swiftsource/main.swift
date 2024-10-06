
func main() {
    let args = CommandLine.arguments
    if args.count > 1 {
        let option = args[1]
        switch option {
        case "--benchmark", "-b":
            benchmark()
        case "--graphics", "-g":
            runGraphics()
        default:
            print("Unknown option: \(option)")
            printUsage()
        }
    } else {
        print("No arguments provided")
        printUsage()
    }
}

// Function to display usage information
func printUsage() {
    print("""
    Usage: SwiftOpenGLApp [option]

    Options:
      --benchmark, -b   Run the benchmark
      --graphics, -g    Run the graphics example
    """)
}

main()
