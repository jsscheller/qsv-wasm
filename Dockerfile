FROM emscripten/emsdk:3.1.10

RUN apt update
RUN apt-get install -y autotools-dev automake libtool pkg-config ninja-build lsb-release libclang1
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup install nightly-2023-04-20
RUN rustup target add wasm32-unknown-emscripten
RUN rustup component add rust-src --toolchain nightly-2023-04-20-x86_64-unknown-linux-gnu
RUN git config --global --add safe.directory '*'
