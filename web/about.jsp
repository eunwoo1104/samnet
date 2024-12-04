<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>
<t:layout>
    <jsp:attribute name="head">
        <style>
            h3 {
                font-size: 1.3rem;
            }
            h3, p {
                margin: 0.2rem 0;
            }
            a {
                text-decoration: none;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <h2>정보</h2>
        <h3>소개</h3>
        <p>
            SamNet는 "삼육대학교 네트워크"의 줄임말로, 객체지향프로그래밍2 MySNS 프로젝트 과제를 위해 제작된 서비스입니다.
        </p>
        <h3 class="mt-lg">
            문서
        </h3>
        <p class="clickable">
            <i class="bi-file-text"></i>
            <a href="${pageContext.request.contextPath}/tos.jsp">
                서비스 이용약관
            </a>
        </p>
        <p class="clickable">
            <i class="bi-file-earmark-lock"></i>
            <a href="${pageContext.request.contextPath}/privacy.jsp">
                개인정보처리방침
            </a>
        </p>
        <h3 class="mt-lg">
            링크
        </h3>
        <p class="clickable">
            <i class="bi-github"></i>
            <a href="https://github.com/eunwoo1104/samnet" target="_blank" rel="noreferrer noopener">GitHub</a>
        </p>
        <p class="clickable">
            <i class="bi-envelope"></i>
            <a href="mailto:choi@eunwoo.dev" target="_blank" rel="noreferrer noopener">이메일</a>
        </p>
    </jsp:body>
</t:layout>