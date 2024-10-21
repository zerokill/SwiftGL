import Foundation

struct Options {
    var benchmark: Bool = false
    var graphics: Bool = false
    var fullscreen: Bool = false
    var program: Int? = nil
    var width: Int32 = 800
    var height: Int32 = 600
}

enum ArgumentError: Error, CustomStringConvertible {
    case missingValue(String)
    case invalidValue(String, String)

    var description: String {
        switch self {
        case .missingValue(let option):
            return "Missing value for \(option)."
        case .invalidValue(let option, let value):
            return "Invalid value '\(value)' for \(option). Expected a numerical identifier."
        }
    }
}

func printUsage() {
    let usage = """
    Usage: \(CommandLine.arguments[0]) [options]

    Options:
      -b, --benchmark           Enable benchmark mode.
      -g, --graphics            Enable graphics mode.
      -f, --fullscreen          Enable fullscreen mode (requires --graphics).
      -p, --program <number>    Specify the program numerical identifier.
      -w, --width <number>      Specify the width. Default: 800
      -h, --height <number>     Specify the height. Default: 600
      -h, --help                Show this help message.
    """
    print(usage)
}

func parseArguments() throws -> Options {
    var options = Options()
    let args = CommandLine.arguments.dropFirst() // Skip the executable name

    var iterator = args.makeIterator()
    while let arg = iterator.next() {
        switch arg {
        case "--benchmark", "-b":
            options.benchmark = true
        case "--graphics", "-g":
            options.graphics = true
        case "--fullscreen", "-f":
            options.fullscreen = true
        case "--program", "-p":
            guard let value = iterator.next() else {
                throw ArgumentError.missingValue("--program")
            }
            if let intValue = Int(value) {
                options.program = intValue
            } else {
                throw ArgumentError.invalidValue("--program", value)
            }
        case "--width":
            guard let value = iterator.next() else {
                throw ArgumentError.missingValue("--width")
            }
            if let intValue = Int32(value) {
                options.width = intValue
            } else {
                throw ArgumentError.invalidValue("--width", value)
            }
        case "--height":
            guard let value = iterator.next() else {
                throw ArgumentError.missingValue("--height")
            }
            if let intValue = Int32(value) {
                options.height = intValue
            } else {
                throw ArgumentError.invalidValue("--height", value)
            }
        case "--help", "-h":
            printUsage()
            exit(0)
        default:
            throw NSError(domain: "Unknown option: \(arg)", code: 1, userInfo: nil)
        }
    }

    // Validation: If fullscreen is set, graphics must also be set
    if options.fullscreen && !options.graphics {
        throw NSError(domain: "--fullscreen requires --graphics to be set.", code: 1, userInfo: nil)
    }

    return options
}


func main() {
    do {
        let options = try parseArguments()
        
        if options.benchmark {
            print("Benchmark mode enabled.")
            benchmark()
        }
        
        if options.graphics {
            print("Graphics mode enabled.")
            runGraphics(options: options)
        }
        
        if !options.benchmark && !options.graphics {
            print("No options selected. Use --help to see available options.")
        }
        
        // Your application logic here
        
    } catch let error as NSError {
        print("Error: \(error.domain)")
        print("Use --help to see available options.")
        exit(1)
    }
}

main()
