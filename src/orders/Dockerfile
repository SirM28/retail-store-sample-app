# ---- Build stage ----
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build-env

# Install dependencies (Java + Maven + utils)
RUN dnf --setopt=install_weak_deps=False install -q -y \
    maven java-21-amazon-corretto-headless shadow-utils gzip tar which && \
    dnf clean all

# Set JAVA_HOME explicitly
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /workspace/app

# Copy Maven wrapper files and pom.xml
COPY mvnw .
COPY .mvn/wrapper/maven-wrapper.jar .mvn/wrapper/maven-wrapper.jar
COPY .mvn/wrapper/maven-wrapper.properties .mvn/wrapper/maven-wrapper.properties
COPY pom.xml .

RUN chmod +x mvnw

# Download dependencies offline
RUN ./mvnw dependency:go-offline -B -q

# Copy source and build
COPY src ./src
RUN ./mvnw package -DskipTests

# ---- Runtime stage ----
FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN dnf --setopt=install_weak_deps=False install -q -y \
    java-21-amazon-corretto-headless shadow-utils which && \
    dnf clean all

# Create a non-root user
RUN useradd --home "/app" --create-home --user-group --uid "1000" "appuser"

WORKDIR /app
USER appuser

# Copy built jar from build stage
COPY --from=build-env /workspace/app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
