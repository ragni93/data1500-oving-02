import com.sun.net.httpserver.*;
import java.io.*;
import java.net.InetSocketAddress;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

/**
 * Oppgave 1: Enkel READ-API
 * 
 * En minimalistisk webserver som tilbyr en HTTP GET-API for å hente studentdata
 * fra en CSV-fil og returnere det som JSON.
 * 
 * Bruk:
 *   java StudentAPI <port> <csv-fil>
 * 
 * Eksempel:
 *   java StudentAPI 8000 studenter.csv
 * 
 * Test:
 *   curl http://localhost:8000/api/students/101
 *   curl http://localhost:8000/api/students
 */
public class StudentAPI {
    
    private static Map<String, Student> students = new HashMap<>();
    private static String csvFilePath;
    
    // Indre klasse for Student
    static class Student {
        int id;
        String name;
        String program;
        
        Student(int id, String name, String program) {
            this.id = id;
            this.name = name;
            this.program = program;
        }
        
        String toJSON() {
            return String.format("{\"id\":%d,\"name\":\"%s\",\"program\":\"%s\"}", 
                id, name, program);
        }
        
        @Override
        public String toString() {
            return String.format("Student{id=%d, name='%s', program='%s'}", 
                id, name, program);
        }
    }
    
    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("Bruk: java StudentAPI <port> <csv-fil>");
            System.exit(1);
        }
        
        int port = Integer.parseInt(args[0]);
        csvFilePath = args[1];
        
        // Last inn CSV-filen
        loadStudentsFromCSV(csvFilePath);
        
        // Opprett HTTP-server
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        // Definer kontekster (endpoints)
        server.createContext("/api/students", StudentAPI::handleStudentsRequest);
        server.createContext("/api/students/", StudentAPI::handleStudentRequest);
        server.createContext("/health", StudentAPI::handleHealthCheck);
        
        server.setExecutor(null); // Bruk default executor
        server.start();
        
        System.out.println("StudentAPI server startet på port " + port);
        System.out.println("Tilgjengelige endepunkter:");
        System.out.println("  GET /api/students          - Hent alle studenter");
        System.out.println("  GET /api/students/{id}     - Hent student med spesifikk ID");
        System.out.println("  GET /health                - Sjekk server-status");
    }
    
    private static void loadStudentsFromCSV(String filePath) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(filePath));
        for (String line : lines) {
            if (line.trim().isEmpty()) continue;
            
            String[] parts = line.split(",");
            if (parts.length >= 3) {
                try {
                    int id = Integer.parseInt(parts[0].trim());
                    String name = parts[1].trim();
                    String program = parts[2].trim();
                    students.put(String.valueOf(id), new Student(id, name, program));
                } catch (NumberFormatException e) {
                    System.err.println("Feil ved parsing av linje: " + line);
                }
            }
        }
        System.out.println("Lastet inn " + students.size() + " studenter fra " + filePath);
    }
    
    private static void handleStudentsRequest(HttpExchange exchange) throws IOException {
        // Hent alle studenter
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Student student : students.values()) {
            if (!first) json.append(",");
            json.append(student.toJSON());
            first = false;
        }
        json.append("]");
        
        sendResponse(exchange, 200, json.toString());
    }
    
    private static void handleStudentRequest(HttpExchange exchange) throws IOException {
        String path = exchange.getRequestURI().getPath();
        String[] parts = path.split("/");
        
        if (parts.length < 4) {
            sendResponse(exchange, 400, "{\"error\":\"Invalid request\"}");
            return;
        }
        
        String studentId = parts[3];
        
        if (students.containsKey(studentId)) {
            Student student = students.get(studentId);
            sendResponse(exchange, 200, student.toJSON());
        } else {
            sendResponse(exchange, 404, "{\"error\":\"Student not found\"}");
        }
    }
    
    private static void handleHealthCheck(HttpExchange exchange) throws IOException {
        sendResponse(exchange, 200, "{\"status\":\"OK\"}");
    }
    
    private static void sendResponse(HttpExchange exchange, int statusCode, String response) 
            throws IOException {
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
        exchange.sendResponseHeaders(statusCode, response.getBytes().length);
        
        OutputStream os = exchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
}
