project "glad"

    kind "StaticLib"
    language "C"

    files
    {
        "include/glad/glad.g"
        "src/glad.c"
    }

    filter "configuration:Debug"
        runtime "Debug"
        symbols "on"
    filter "configuration:Release"
        runtime "Release"
        optimize "on"