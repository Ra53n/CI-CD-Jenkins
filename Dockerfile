FROM antonkazakov/otus

ENV VERSION_SDK_TOOLS "9477386_latest"
ENV ANDROID_SDK_ROOT "/sdk"
ENV ANDROID_HOME $ANDROID_SDK_ROOT
ENV GRADLE_PROFILER_VERSION "0.20.0"
ENV GRADLE_PROFILER "/gradle-profiler"
ENV PATH "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/platform-tools/bin:${ANDROID_SDK_ROOT}/tools/:${ANDROID_SDK_ROOT}/tools/bin:${GRADLE_PROFILER}/bin:${PATH}"

RUN  echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" | cat - ~/.bashrc >> temp && mv temp ~/.bashrc

RUN mkdir -p ${GRADLE_PROFILER} \
    && cd ${GRADLE_PROFILER} \
    && wget -O GradleProfiler.zip https://repo1.maven.org/maven2/org/gradle/profiler/gradle-profiler/${GRADLE_PROFILER_VERSION}/gradle-profiler-${GRADLE_PROFILER_VERSION}.zip \
    && unzip GradleProfiler.zip -d ${GRADLE_PROFILER}\
    && rm -v GradleProfiler.zip

RUN mkdir -p $ANDROID_SDK_ROOT && \
    chown -R jenkins $ANDROID_SDK_ROOT

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_SDK_TOOLS}.zip > $ANDROID_SDK_ROOT/sdk.zip && \
  mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
  unzip $ANDROID_SDK_ROOT/sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
  mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
  rm -v $ANDROID_SDK_ROOT/sdk.zip

ADD --chown=jenkins packages.txt $ANDROID_SDK_ROOT

RUN mkdir -p $HOME/.android && \
  touch $HOME/.android/repositories.cfg

RUN yes | sdkmanager --licenses && \
    sdkmanager --package_file=$ANDROID_SDK_ROOT/packages.txt

# switch to user jenkins
USER jenkins