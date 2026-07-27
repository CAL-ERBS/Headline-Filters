<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audio Recorder</title>
</head>
<body>
    <h1>Voice Recorder</h1>
    <button id="startBtn">Start Recording</button>
    <button id="stopBtn" disabled>Stop Recording</button>
    <audio id="audioPlayback" controls></audio>
    <a id="downloadLink" style="display:none;">Download Recording</a>

    <script>
        let mediaRecorder;
        let audioChunks = [];

        // Get access to the microphone
        navigator.mediaDevices.getUserMedia({ audio: true })
            .then(stream => {
                mediaRecorder = new MediaRecorder(stream);

                // When data is available, push it to the audioChunks array
                mediaRecorder.ondataavailable = event => {
                    audioChunks.push(event.data);
                };

                // When recording stops, create a Blob and provide a download link
                mediaRecorder.onstop = () => {
                    const audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                    const audioUrl = URL.createObjectURL(audioBlob);
                    const audioPlayback = document.getElementById('audioPlayback');
                    audioPlayback.src = audioUrl;

                    // Create a download link for the audio file
                    const downloadLink = document.getElementById('downloadLink');
                    downloadLink.href = audioUrl;
                    downloadLink.download = 'recording.wav';
                    downloadLink.style.display = 'block';
                    downloadLink.innerText = 'Download Recording';
                };
            });

        // Start recording
        document.getElementById('startBtn').onclick = () => {
            audioChunks = []; // Reset audio chunks
            mediaRecorder.start();
            document.getElementById('startBtn').disabled = true;
            document.getElementById('stopBtn').disabled = false;
        };

        // Stop recording
        document.getElementById('stopBtn').onclick = () => {
            mediaRecorder.stop();
            document.getElementById('startBtn').disabled = false;
            document.getElementById('stopBtn').disabled = true;
        };
    </script>
</body>
</html>
