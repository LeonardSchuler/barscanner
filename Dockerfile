# Define global args
ARG FUNCTION_DIR="/home/app/"
ARG RUNTIME_VERSION="3.9"
ARG DISTRO_VERSION="3.13"

# Stage 1 - bundle base image + runtime
# Grab a fresh copy of the image and install GCC
FROM python:${RUNTIME_VERSION}-alpine${DISTRO_VERSION} AS python-alpine
# Install GCC (Alpine uses musl but we compile and link dependencies with GCC)
RUN apk add --no-cache \
    libstdc++

# Stage 2 - build function and dependencies
FROM python-alpine AS build-image
# Install aws-lambda-cpp build dependencies
RUN apk add --no-cache \
    build-base \
    libtool \
    autoconf \
    automake \
    libexecinfo-dev \
    make \
    cmake \
    libcurl
RUN apk add --no-cache zbar
# Include global args in this stage of the build
ARG FUNCTION_DIR
ARG RUNTIME_VERSION
# Create function directory
RUN mkdir -p ${FUNCTION_DIR}
# Copy handler function
COPY src/pyzbar ${FUNCTION_DIR}/pyzbar
COPY src/pyzbar-0.1.9.dist-info ${FUNCTION_DIR}/pyzbar-0.1.9.dist-info
COPY requirements.txt /tmp/requirements.txt
# Optional – Install the function's dependencies
# RUN python${RUNTIME_VERSION} -m pip install -r requirements.txt --target ${FUNCTION_DIR}
# Install Lambda Runtime Interface Client for Python
#RUN python${RUNTIME_VERSION} -m pip install awslambdaric --target ${FUNCTION_DIR}
RUN python${RUNTIME_VERSION} -m pip install -v -r /tmp/requirements.txt --target ${FUNCTION_DIR}

# Stage 3 - final runtime image
# Grab a fresh copy of the Python image
FROM python-alpine
# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}
# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY --from=build-image /usr/bin/zbarimg /usr/bin/zbarimg 
COPY --from=build-image /usr/lib/libzbar.so.0 /usr/lib/libzbar.so.0
COPY --from=build-image /usr/lib/libdbus-1.so.3 /usr/lib/libdbus-1.so.3
COPY --from=build-image /usr/lib/libX11.so.6 /usr/lib/libX11.so.6
COPY --from=build-image /usr/lib/libXv.so.1 /usr/lib/libXv.so.1
COPY --from=build-image /usr/lib/libjpeg.so.8 /usr/lib/libjpeg.so.8
COPY --from=build-image /usr/lib/libxcb.so.1 /usr/lib/libxcb.so.1
COPY --from=build-image /usr/lib/libXext.so.6 /usr/lib/libXext.so.6
COPY --from=build-image /usr/lib/libXau.so.6 /usr/lib/libXau.so.6
COPY --from=build-image /usr/lib/libXdmcp.so.6 /usr/lib/libXdmcp.so.6
COPY --from=build-image /usr/lib/libbsd.so.0 /usr/lib/libbsd.so.0
#COPY --from=build-image /usr/lib /usr/lib
# (Optional) Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh /
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh
COPY src/app/* ${FUNCTION_DIR}
ENTRYPOINT [ "/entry.sh" ]
CMD [ "app.lambda_handler" ]
